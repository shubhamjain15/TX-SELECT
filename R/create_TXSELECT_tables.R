loc_TXSELECT_files <- "./Output/TXSELECT_data/"
#1. counties.csv
TXSELECT_counties <- tbl_counties 
TXSELECT_counties <- TXSELECT_counties%>%
                        left_join(tbl_nass, by = "GEOID")%>%
                        select(c("NAME","GEOID","Area","Length","CATTLE","EQUINE","GOATS","SHEEP"))%>%
                        rename(c(Name = "NAME",GeoId = "GEOID",Cattle = "CATTLE",
                                 Equine = "EQUINE", Goats = "GOATS",Sheep = "SHEEP"))

write_csv(TXSELECT_counties, paste0(loc_TXSELECT_files, "counties.csv"))

#2. counties_landcover.csv
TXSELECT_counties_landcover <- tbl_counties%>%
                                select(c("GEOID","NAME"))%>%
                                left_join(tbl_lc_counties, by = "GEOID")%>%
                                select(-"Perennial.Snow.Ice")%>%
                                rename(c(Name = "NAME",GeoId = "GEOID",
                                         NoData = "Unclassified",OpenWater = "Open.Water",DevelopedOpenSpace = "Developed..Open.Space",
                                         DevelopedLow = "Developed..Low.Intensity",DevelopedMedium = "Developed..Medium.Intensity",
                                         DevelopedHigh = "Developed..High.Intensity",Barren = "Barren.Land",DeciduousForest = "Deciduous.Forest",
                                         EvergreenForest = "Evergreen.Forest",MixedForest = "Mixed.Forest",Shrub = "Shrub.Scrub",Grassland = "Herbaceous",
                                         Pasture = "Hay.Pasture",CultivatedCrop = "Cultivated.Crops",WoodyWetland = "Woody.Wetlands",EmergentWetland = "Emergent.Herbaceous.Wetlands"))

write_csv(TXSELECT_counties_landcover, paste0(loc_TXSELECT_files, "counties_landcover.csv"))

#3. counties_to_subbasins.csv
TXSELECT_counties_to_subbasins <- tbl_counties%>%
                                    select(c("GEOID","NAME"))%>%
                                    left_join(tbl_lc_subbasins_counties, by = "GEOID")%>%
                                    select(-"Perennial.Snow.Ice")%>%
                                    rename(c(Name = "NAME",GeoId = "GEOID",
                                             NoData = "Unclassified",OpenWater = "Open.Water",DevelopedOpenSpace = "Developed..Open.Space",
                                             DevelopedLow = "Developed..Low.Intensity",DevelopedMedium = "Developed..Medium.Intensity",
                                             DevelopedHigh = "Developed..High.Intensity",Barren = "Barren.Land",DeciduousForest = "Deciduous.Forest",
                                             EvergreenForest = "Evergreen.Forest",MixedForest = "Mixed.Forest",Shrub = "Shrub.Scrub",Grassland = "Herbaceous",
                                             Pasture = "Hay.Pasture",CultivatedCrop = "Cultivated.Crops",WoodyWetland = "Woody.Wetlands",EmergentWetland = "Emergent.Herbaceous.Wetlands"))

write_csv(TXSELECT_counties_to_subbasins, paste0(loc_TXSELECT_files, "counties_to_subbasins.csv"))

#4. select_dataset.csv
df <- st_transform(gis_subbasins, crs = 4326)
bbox <- st_bbox(df)
TXSELECT_select_dataset <- data.frame(Name = "HUC12", Description = "", Attribution = "",
                                      MaxLat = as.numeric(bbox["ymax"]),MinLat = as.numeric(bbox["ymin"]),
                                      MaxLon = as.numeric(bbox["xmax"]),MinLon = as.numeric(bbox["xmin"]))

write_csv(TXSELECT_select_dataset, paste0(loc_TXSELECT_files, "select_dataset.csv"))

rm(df,bbox)

#5. subbasins_data.csv
TXSELECT_subbasins_data <- st_drop_geometry(gis_subbasins)%>%
                                select(-c("PolygonId","Subbasin"))%>%
                                left_join(tbl_ecoregion%>%select(c("HUC12","NA_L3CODE","NAL3KEY")), by = "HUC12")%>%
                                left_join(tbl_hu20_ossf, by ="HUC12")%>%
                                left_join(tbl_ossfs_1990, by = "HUC12")%>%
                                left_join(tbl_ossfs_911, by = "HUC12")%>%
                                left_join(tbl_ossfs_coastal,by = "HUC12")%>%
                                left_join(tbl_ssurgo, by = "HUC12")%>%
                                left_join(tbl_census20,by = "HUC12")%>%
                                left_join(tbl_livestock_counts, by = "HUC12")%>%
                                rename(Subbasin = "HUC12",Population = "Pop",HousingUnits = "HU",SoilDrainfieldClass = "Septic_class",NAL3Code = NA_L3CODE)

write_csv(TXSELECT_subbasins_data, paste0(loc_TXSELECT_files, "subbasins_data.csv"))

#6. subbasins_hogs_landcover.csv
TXSELECT_hogs_landcover <- tbl_lc_subbasins%>%
                              select(-"Perennial.Snow.Ice")%>%
                              rename(c(NoData = "Unclassified",OpenWater = "Open.Water",DevelopedOpenSpace = "Developed..Open.Space",
                                       DevelopedLow = "Developed..Low.Intensity",DevelopedMedium = "Developed..Medium.Intensity",
                                       DevelopedHigh = "Developed..High.Intensity",Barren = "Barren.Land",DeciduousForest = "Deciduous.Forest",
                                       EvergreenForest = "Evergreen.Forest",MixedForest = "Mixed.Forest",Shrub = "Shrub.Scrub",Grassland = "Herbaceous",
                                       Pasture = "Hay.Pasture",CultivatedCrop = "Cultivated.Crops",WoodyWetland = "Woody.Wetlands",EmergentWetland = "Emergent.Herbaceous.Wetlands"))

write_csv(TXSELECT_hogs_landcover, paste0(loc_TXSELECT_files, "subbasins_hogs_landcover.csv"))

#7. subbasins_landcover.csv
TXSELECT_subbasins_landcover <- tbl_lc_subbasins%>%
                                    select(-"Perennial.Snow.Ice")%>%
                                    rename(c(NoData = "Unclassified",OpenWater = "Open.Water",DevelopedOpenSpace = "Developed..Open.Space",
                                             DevelopedLow = "Developed..Low.Intensity",DevelopedMedium = "Developed..Medium.Intensity",
                                             DevelopedHigh = "Developed..High.Intensity",Barren = "Barren.Land",DeciduousForest = "Deciduous.Forest",
                                             EvergreenForest = "Evergreen.Forest",MixedForest = "Mixed.Forest",Shrub = "Shrub.Scrub",Grassland = "Herbaceous",
                                             Pasture = "Hay.Pasture",CultivatedCrop = "Cultivated.Crops",WoodyWetland = "Woody.Wetlands",EmergentWetland = "Emergent.Herbaceous.Wetlands"))

write_csv(TXSELECT_subbasins_landcover, paste0(loc_TXSELECT_files, "subbasins_landcover.csv"))

#8. wwtf.csv
TXSELECT_wwtf <- tbl_WWTF_facs%>%
                    select(c("FacDerivedWBD","SourceID","CWPName","CWPStreet","CWPCity","CWPState","FacLat","FacLong",
                             "Ecoli_MPN","Flow_MGD"))%>%
                    rename(c(Subbasin = "FacDerivedWBD",FacilityID = "SourceID", FacilityName = "CWPName",
                             FacilityStreet = "CWPStreet",FacilityCity = "CWPCity",FacilityState = "CWPState",
                             FacilityLatitude = "FacLat",FacilityLongitude = "FacLong",
                             EColiDailyAverage = "Ecoli_MPN",FlowLimit = "Flow_MGD" ))

write_csv(TXSELECT_wwtf, paste0(loc_TXSELECT_files, "wwtf.csv"))

#9. subbasins_from_to.csv


#10. subbasins.geojson

#11. subbasins_streams.geojson