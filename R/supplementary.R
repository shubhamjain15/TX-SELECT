#1. 911 addresses
png(filename = "./Output/counties_911.png",height = 5.5, width = 6.5, res = 600, units = "in")
ggplot() +
  geom_sf(data = gis_counties_with911, aes(fill = factor(ifelse(Join_Count > 0, "Data available", "Missing/No Data")))) +
  scale_fill_manual(values = c("Missing/No Data" = "transparent", "Data available" = "darkgrey")) +
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
  theme(legend.position = c(0.2,.18))+
  theme(plot.margin = unit(c(0, 0, 0, 0), "cm"),
        text = element_text(family = "serif"))+
  theme(legend.title=element_blank())
dev.off()

#2. CCN+UA map
gis_CCN_UA_withinHUC <- st_intersection(gis_CCN_UA,gis_subbasins)

png(filename = "./Output/UA_CCN.png",height = 5.5, width = 6.5, res = 600, units = "in")
ggplot()+
  geom_sf(data = gis_subbasins,aes(color = "HUC12 Subwatersheds",fill = "HUC12 Subwatersheds"))+
  scale_color_manual(values = "grey", name = NULL, guide = guide_legend(order = 1)) +
  scale_fill_manual(values = "transparent", name = NULL, guide = guide_legend(order = 1)) +
  ggnewscale::new_scale_fill() +
  ggnewscale::new_scale_color() +
  geom_sf(data = gis_texas_boundary, aes(color = "Texas state boundary",fill = "Texas state boundary"))+
  scale_color_manual(values = "black", name = NULL, guide = guide_legend(order = 2)) +
  scale_fill_manual(values = "transparent", name = NULL, guide = guide_legend(order = 2)) +
  ggnewscale::new_scale_fill() +
  ggnewscale::new_scale_color() +
  geom_sf(data = gis_CCN_UA_withinHUC, aes(color = "Estimated sewer service areas",fill = "Estimated sewer service areas"))+
  scale_color_manual(values = "transparent", name = NULL, guide = guide_legend(order = 3)) +
  scale_fill_manual(values = "red", name = NULL, guide = guide_legend(order = 3)) +
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
  theme(legend.position = c(0.2,.18))+
  theme(plot.margin = unit(c(0, 0, 0, 0), "cm"),
        text = element_text(family = "serif"))
dev.off()

