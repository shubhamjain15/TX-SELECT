#1. ATTAINS data################################################################
tbl_ATTAINS_lines <- st_drop_geometry(gis_ATTAINS_lines)%>%select("HUC12","recreation")
tbl_ATTAINS_poly <- st_drop_geometry(gis_ATTAINS_poly)%>%select("HUC12", "recreation")

tbl_ATTAINS <- rbind(tbl_ATTAINS_lines,tbl_ATTAINS_poly)

tbl_ATTAINS <- tbl_ATTAINS%>%
                        group_by(HUC12)%>%
                        summarize(Status = case_when(
                          any(recreation == "Not Supporting") ~ "Not Supporting",
                          any(recreation == "Fully Supporting") & any(recreation != "Not Supporting") ~ "Fully Supporting",
                          TRUE ~ "Not Assessed"
                        ))

table(tbl_ATTAINS$Status)

#2. Urban/Rural class###########################################################
tbl_urban_metrics <- TXSELECT_subbasins_data%>%
                      select(c("Subbasin","Area","HousingUnits"))%>%
                      left_join(TXSELECT_subbasins_landcover, by = c("Subbasin" = "HUC12"))%>%
                      mutate(Developed_Perc = (DevelopedOpenSpace+DevelopedLow + DevelopedMedium + DevelopedHigh)*100/Area)%>%
                      mutate(Housingkm2= HousingUnits/(Area*10-6))%>%
                      mutate(type = case_when(
                        Housingkm2 > 200 | Developed_Perc > 20  ~ "Urban",
                        TRUE ~ "Rural"
                      ))%>%
                      select(c("Subbasin","type"))

#3. Summarize###################################################################
final_load_hectares <- Load_hectares%>%
                            mutate(Goats_Sheep = Goats+Sheep)%>%
                            mutate(Pets = Dogs + Cats)%>%
                            select(-c("Dogs","Cats","Goats","Sheep"))%>%
                            mutate(Total = Cattle + Goats_Sheep + Pets + Equine + FailingOSSFs + WWTF + Deer + Hogs)%>%
                            left_join(tbl_ATTAINS, join_by("Subbasin" == "HUC12"))%>%
                            left_join(tbl_urban_metrics, by = "Subbasin")%>%
                            mutate(HUC02 = substr(Subbasin,1,2))

final_counts <- counts_all%>%
                    mutate(Goats_Sheep = Goats+Sheep)%>%
                    mutate(Pets = Dogs + Cats)%>%
                    select(-c("Dogs","Cats","Goats","Sheep"))%>%
                    mutate(HUC02 = substr(Subbasin,1,2))

#4. Statistical analysis########################################################

