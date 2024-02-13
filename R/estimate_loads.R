#Livestock
#Change livestock SR for specific counties and recalculate livestock numbers
#Update counties cattle SR if >0.3333 animal per acre (3 acres per AU) to 0.3333
tbl_livestock_SR_updated <- tbl_livestock_SR
tbl_livestock_SR_updated$CATTLE_SR[tbl_livestock_SR_updated$CATTLE_SR > 0.3333] <- 0.3333
counts_livestock <- tbl_lc_subbasins_counties%>%
                      rowwise()%>%
                      mutate(suitable_livestock_sub = (Shrub.Scrub+Herbaceous+Hay.Pasture)/4046.86)%>%   #per acre
                      select(c("HUC12","GEOID","suitable_livestock_sub"))%>%
                      left_join(tbl_livestock_SR_updated, by = "GEOID")%>%
                      mutate(Cattle_sub = CATTLE_SR*suitable_livestock_sub)%>%
                      mutate(Equine_sub = EQUINE_SR*suitable_livestock_sub)%>%
                      mutate(Goats_sub = GOATS_SR*suitable_livestock_sub)%>%
                      mutate(Sheep_sub = SHEEP_SR*suitable_livestock_sub)%>%
                      group_by(HUC12)%>%
                      summarise(Cattle = round(sum(Cattle_sub),0),
                                Equine = round(sum(Equine_sub),0),
                                Goats = round(sum(Goats_sub),0),
                                Sheep = round(sum(Sheep_sub),0))

#Pets
counts_pets <- TXSELECT_subbasins_data%>%
                      mutate(Dogs = round(0.614*HousingUnits))%>%
                      mutate(Cats = round(0.457*HousingUnits))%>%
                      select(c("Subbasin","Dogs","Cats"))

#Deer
counts_deer <- tbl_ecoregion%>%
                      left_join(tbl_lc_subbasins, by ="HUC12")%>%
                      rowwise()%>%
                      mutate(suitable_lc = (Deciduous.Forest+Evergreen.Forest+Mixed.Forest+Shrub.Scrub+Herbaceous+
                                              Hay.Pasture+Cultivated.Crops+Woody.Wetlands+Emergent.Herbaceous.Wetlands)/4046.86)%>%
                      mutate(Deer = round(suitable_lc*Density/1000,0))%>%
                      select(c("HUC12","Deer"))

#Hogs
counts_hogs <- tbl_lc_subbasins%>%
                      left_join(tbl_prism, by = "HUC12")%>%
                      mutate(density = ifelse(PRCP >= 508, 33.3, 76))%>%       #33.3 acres per hog if prcp > 1000 mm otherwise 70
                      rowwise()%>%
                      mutate(suitable_lc = (Deciduous.Forest+Evergreen.Forest+Mixed.Forest+Shrub.Scrub+Herbaceous+
                                              Hay.Pasture+Cultivated.Crops+Woody.Wetlands+Emergent.Herbaceous.Wetlands)/4046.86)%>%
                      mutate(Hogs = round(suitable_lc/density,0))%>%
                      select(c("HUC12","Hogs"))

#OSSFs
counts_ossfs <- TXSELECT_subbasins_data%>%
                      select(c("Subbasin","SoilDrainfieldClass","OssfHousingUnits"))%>%
                      mutate(FailureRate = case_when(
                        SoilDrainfieldClass == "Very limited" ~ 15,
                        SoilDrainfieldClass == "Somewhat limited" ~ 10,
                        SoilDrainfieldClass == "Not rated" ~ 8,
                        SoilDrainfieldClass == "Not limited" ~ 5,
                        TRUE ~ NA_real_
                      ))%>%
                      mutate(FailingOSSFs = round(OssfHousingUnits * FailureRate/100,0))%>%
                      select("Subbasin","FailingOSSFs")

#WWTFs
counts_wwtf <- TXSELECT_wwtf%>%
                  select(c("Subbasin","EColiDailyAverage","FlowLimit"))%>%
                  mutate(Load = EColiDailyAverage*FlowLimit*10^6*3758.2/100)%>%  #CFU/day
                  group_by(Subbasin)%>%
                  summarise(WWTF = sum(Load))


#Join all counts
##Area in ha
##WWTP is total load and not count
counts_all <- TXSELECT_subbasins_data%>%
                  select(c("Subbasin","Area","Population","HousingUnits"))%>%
                  mutate(Area_ha = Area*0.0001)%>%
                  select(-"Area")%>%
                  left_join(counts_livestock,join_by("Subbasin" == "HUC12"))%>%
                  left_join(counts_pets)%>%
                  left_join(counts_hogs, join_by("Subbasin" == "HUC12"))%>%
                  left_join(counts_deer, join_by("Subbasin" == "HUC12"))%>%
                  left_join(counts_ossfs)%>%
                  left_join(counts_wwtf)%>%                                    #CFU/day
                  replace(is.na(.), 0)

##Calculate load
Load_hectares <- counts_all%>%
                    mutate(Cattle = Cattle*0.63*8.55*10^9/Area_ha)%>%
                    mutate(Sheep = Sheep*0.63*5.8*10^10/Area_ha)%>%
                    mutate(Goats = Goats*0.63*4.32*10^9/Area_ha)%>%
                    mutate(Equine = Equine*0.63*3.64*10^8/Area_ha)%>%
                    mutate(Deer = Deer*0.63*1.68*10^9/Area_ha)%>%
                    mutate(Hogs = Hogs*0.63*1.51*10^8/Area_ha)%>%
                    mutate(Dogs = Dogs*0.63*5*10^9/Area_ha)%>%
                    mutate(Cats = Cats*0.63*5*10^9/Area_ha)%>%
                    mutate(FailingOSSFs = FailingOSSFs*(Population/HousingUnits)*(10^7/100)*70*3758.2*0.63/Area_ha)%>%
                    mutate(WWTF = WWTF/Area_ha)%>%
                    replace(is.na(.), 0)

rm(counts_deer,counts_hogs,counts_livestock,counts_ossfs,counts_pets,counts_wwtf)
write.csv(Load_hectares,"Output/Load_hectares.csv")
write.csv(counts_all,"Output/Counts_all.csv")


