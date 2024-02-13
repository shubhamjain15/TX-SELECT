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
          summarise(Maximum = max(Load),
                    Median = median(Load))%>%
          pivot_wider(names_from = HUC02, values_from = c("Maximum","Median"))%>%
          select(c("Source","Maximum_11","Median_11","Maximum_12","Median_12","Maximum_13","Median_13"))

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
