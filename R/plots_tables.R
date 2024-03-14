#check if factor is changing the order of values
#1. Table - Summary of potential loads##########################################
#Animal counts
total_counts <- final_counts%>%
                  select(c("Cattle","Goats_Sheep","Equine","Deer","Hogs","FailingOSSFs","Pets"))%>%
                  summarise_all(sum)%>%
                  pivot_longer(cols = everything(),names_to = "Source", values_to = "Count")%>%
                  mutate(Count = round(Count*10^-6,2))

#Loads by region                  
df <- final_load_hectares%>%
          select(-c("Population","HousingUnits","Area_ha","Status","type"))%>%
          pivot_longer(cols = -c("Subbasin","HUC02"), names_to = "Source", values_to = "Load")%>%
          mutate(Load = round(Load*10^-6,2))%>%
          group_by(HUC02,Source)%>%
          summarise(Maximum = round(max(Load),2),
                    Mean = round(mean(Load),2))%>%
          pivot_wider(names_from = HUC02, values_from = c("Maximum","Mean"))%>%
          select(c("Source","Maximum_11","Mean_11","Maximum_12","Mean_12","Maximum_13","Mean_13"))

#reorder rows
df$Source <- factor(df$Source, levels = c("Cattle","Goats_Sheep","Equine","Deer","Hogs","FailingOSSFs","Pets","WWTF","Total"))
df <- df%>%
        arrange(Source)

#add counts to loads table
df <- total_counts%>%
          right_join(df, by = "Source")

write.csv(df,"./Output/summary_loads_region.csv")
rm(df,total_counts)

#2. Table - Median loads by watershed class#####################################
df <- final_load_hectares%>%
        select(-c("Subbasin","Population","HousingUnits","Area_ha","HUC02"))%>%
        pivot_longer(cols = -c("type","Status"), names_to = "Source", values_to = "Load")%>%
        mutate(Load = round(Load*10^-6,2))%>%
        group_by(type,Status,Source)%>%
        summarise(Median = round(median(Load),2))%>%
        pivot_wider(names_from = c("type","Status"), values_from = Median)%>%
        select(c("Source","Rural_Not Supporting","Rural_Fully Supporting","Rural_Not Assessed",
                 "Urban_Not Supporting","Urban_Fully Supporting","Urban_Not Assessed"))

df$Source <- factor(df$Source, levels = c("Cattle","Goats_Sheep","Equine","Deer","Hogs","FailingOSSFs","Pets","WWTF","Total"))
df <- df%>%
       arrange(Source)                 

#Add counts of HUC12s in each class
df2 <- data.frame(table(final_load_hectares%>%select("type","Status")))%>%
            mutate(type_status = paste0(type,"_",Status))%>%
            select(c("type_status","Freq"))%>%
            pivot_wider(names_from = type_status, values_from = Freq)%>%
            select(c("Rural_Not Supporting","Rural_Fully Supporting","Rural_Not Assessed",
                     "Urban_Not Supporting","Urban_Fully Supporting","Urban_Not Assessed"))%>%
            cross_join(data.frame(Source = "N"))

df <- rbind(df,df2)

write.csv(df,"./Output/summary_loads_typeClass.csv")
rm(df,df2)


#3. Plot - Loads from Sources###################################################
gis_subbasin_loads <- gis_HUC12_simplified%>%
                          left_join(final_load_hectares, join_by("HUC12" == "Subbasin"))%>%
                          select(c("Cattle","Goats_Sheep","Equine","Deer","Hogs","FailingOSSFs","Pets","WWTF","Total"))%>%
                          pivot_longer(cols = -geometry,names_to = "Source", values_to = "Load")%>%
                          group_by(Source)%>%                        
                          mutate(Load = cut(Load, 
                                            breaks = c(-1,classIntervals(Load, n = 99, style = "kmeans")$brks), 
                                            labels = FALSE))

gis_subbasin_loads$Source <- factor(gis_subbasin_loads$Source,levels = c("Cattle","Goats_Sheep","Equine","Deer","Hogs","FailingOSSFs","Pets","WWTF","Total") )

gis_subbasin_loads <- gis_subbasin_loads%>%
                          arrange(Source)

png("Output/loads.png",height = 7.6, width = 6.5, res = 600, units = "in")
ggplot()+
  geom_sf(data = gis_subbasin_loads,aes(fill = Load), color = NA)+
  geom_sf(data = gis_texas_boundary, fill = "transparent", color = "black")+
  scale_fill_viridis_c(option = "H", direction = 1, begin = 0.2, end = 0.9, 
                       breaks = c(1,25,50,75,90),
                       labels = c("Negligible", "Low", "Moderate", "High", "Very High"))+
  facet_wrap(~ Source, ncol = 3,labeller = custom_labeller)+
  theme_bw()+
  theme(
    panel.background = element_blank(),   
    panel.grid.major = element_blank(),   
    panel.grid.minor = element_blank(),   
    panel.border = element_blank(),       
    axis.text = element_blank(),       
    axis.ticks = element_blank(),
    legend.margin = margin(0, 0, 0, 0),  
    legend.box.margin = margin(0, 0, 0, 0))+
  theme(legend.position = "bottom")+
  theme(legend.key.width = unit(1.1, "in"),
        legend.title = element_text(face = "bold", size = 12),
        plot.margin = unit(c(0, 0, 0, 0), "cm"),
        text = element_text(family = "serif"))+
  labs(fill = expression("Potential"~italic("E. coli")~"load"))+
  guides(fill = guide_colourbar(title.position = "top"))
dev.off()


#4. Plot - Distribution of Total loads##########################################
df <- final_load_hectares%>%
          select(c("Total","type","Status"))%>%
          pivot_longer(cols = -c(type, Status), names_to = "Source",values_to = "Load")%>%
          unite(type_status, type, Status, sep = "-")%>%
          mutate(type_status = factor(type_status,levels = c("Rural-Not Supporting","Rural-Fully Supporting","Rural-Not Assessed","Urban-Not Supporting","Urban-Fully Supporting","Urban-Not Assessed")))

df <- df%>%
         filter(Source == "Total")

plot_dist <- ggplot(df, aes(x = type_status, y = Load,fill = type_status,lower = quantile(Load,0.25), middle = mean(Load), upper = quantile(Load, 0.75))) +
                  stat_boxplot(geom ='errorbar', width = 0.6) +
                  geom_boxplot(alpha = 1, pch = 16)+
                  scale_y_log10(limits = c(2*10^7,3*10^10))+
                  theme_bw()+
                  scale_fill_grey(start = 0.6, end = 0.95)+
                  theme(legend.position = "None")+
                  ylab("Total Load (CFU/hectare-day)")+
                  xlab("")+
                  scale_x_discrete(labels = str_wrap(c("Rural-Not Supporting","Rural-Fully Supporting","Rural-Not Assessed","Urban-Not Supporting","Urban-Fully Supporting","Urban-Not Assessed" ), width = 10)) +
                  theme(text = element_text(size = 9))+
                  geom_text(aes(x = "Rural-Not Supporting", y = 10^10,
                                hjust = 1.3, vjust = -3,
                                label = "(a)",size = 2))+
                  theme(text = element_text(family = "serif", color = "black"),axis.text = element_text(color = "black"))
                                                                      

explain_boxplot <- ggplot_box_legend()
plot_top <- plot_grid(plot_dist,
                      explain_boxplot,
                      nrow = 1, rel_widths = c(.65,.35))
plot_top

#5. Plot - Distribution of Dominant loads#######################################
df <- final_load_hectares %>%
  filter(Total > 0)%>%    #subbasins where all loads are zero
  select(c("Subbasin", "Cattle", "Goats_Sheep", "Equine", "Deer", "Hogs", "FailingOSSFs", "Pets", "WWTF")) %>%
  pivot_longer(cols = -Subbasin, names_to = "Source", values_to = "Load") %>%
  group_by(Subbasin) %>%
  mutate(Rank = dense_rank(desc(Load))) %>%
  filter(Rank <= 2) %>%
  select(Subbasin, Source, Rank) %>%
  ungroup()%>%
  group_by(Subbasin,Rank)
  
remove <- df%>%   #subbasins where most loads are zero
            group_by(Subbasin,Rank)%>%
            summarise(n = n(), .groups = "drop")%>%
            filter(n > 1)
df <- df%>%
       filter(!Subbasin %in% remove$Subbasin)%>%
       mutate(Source = case_when(Source == "Goats_Sheep" ~ "Goats & Sheep",
                                 Source == "FailingOSSFs" ~ "Failing OSSFs",
                                 Source == "Hogs" ~ "Feral Hogs",
                                 TRUE ~ Source))%>%
       pivot_wider(names_from = Rank, values_from = c(Source))
       

names(df) <- c("Subbasin","Source1","Source2")
gis_dominant_source <-  gis_HUC12_simplified%>%
                            left_join(df, join_by("HUC12" == "Subbasin"))%>%
                            filter(!is.na(Source2))   #NA introduced from the subbasins that were removed earlier
                            

gis_dominant_source <- gis_dominant_source%>%
                          pivot_longer(cols = c("Source1", "Source2"), names_to = "Rank", values_to = "Source")

plot_bottom <- ggplot()+
                  geom_sf(data = gis_dominant_source,aes(fill = Source), color = NA)+
                  geom_sf(data = gis_texas_boundary, fill = "transparent", color = "black")+
                  facet_wrap(~ Rank, ncol = 2, labeller = labeller(Rank = c("Source1" = "(b) Most dominant source",
                                                                            "Source2"= "(c) Second most dominant source")))+
                  theme_bw()+
                  theme(
                    panel.background = element_blank(),   
                    panel.grid.major = element_blank(),   
                    panel.grid.minor = element_blank(),   
                    panel.border = element_blank(),       
                    axis.text = element_blank(),       
                    axis.ticks = element_blank(),
                    legend.margin = margin(0, 0, 0, 0),  
                    legend.box.margin = margin(0, 0, 0, 0))+
                  theme(legend.position = "bottom")+
                  theme(legend.title = element_text(face = "bold", size = 12),
                        plot.margin = unit(c(0, 0, 0, 0), "cm"))+
                  theme(strip.text = element_text(size = 10),text = element_text(family = "serif"))

plot_bottom
#Merged plot ###################################################################
png(filename = "./Output/load_comp.png",height = 7, width = 6.5, res = 600, units = "in")
ggarrange(plot_top,plot_bottom,ncol = 1)
dev.off()

rm(plot_top,plot_bottom,df,gis_dominant_source,remove,plot_dist)
