source("load_libraries.R")
load(file = "env_data.RData")
source("load_data.R")

#1.1. Prepare HUC12 to/from##################################################### 
################################################################################
tbl_subbasins <- st_drop_geometry(gis_subbasins%>%select("HUC12","NAME"))       #Make sure HUC12 is character and has length 12
tbl_counties <- st_drop_geometry(gis_counties%>%select("GEOID", "NAME"))

#1.2. Land cover################################################################
#Get land cover area for each subbasin##########################################
res(gis_nlcd)                                                                   #30m x 30 m raster
results <- list()
for(i in 1:nrow(gis_subbasins)){
  poly <- gis_subbasins[i,]
  df <- data.frame(table(terra::extract(gis_nlcd,poly))*res(gis_nlcd)[1] * res(gis_nlcd)[2])
  df$nlcd_2019 <- paste0("VALUE_",df$nlcd_2019)                                 #change lc class values to columns names 
  df <- df%>%
          select(c("nlcd_2019", "Freq"))%>%
          pivot_wider(names_from = nlcd_2019, values_from = Freq)
  results[[i]] <- data.frame(HUC12 = gis_subbasins$HUC12[i],df)
}

tbl_lc_subbasins <- do.call(bind_rows, results)                                 #Area in square meters
tbl_lc_subbasins[is.na(tbl_lc_subbasins)] <- 0

rm(results,poly,i,df)

#1.3. Census data###############################################################
################################################################################
pop20 <- round(exact_extract(gis_pop20,
                             st_as_sf(gis_subbasins),
                             fun = "sum",
                             force_df = TRUE,
                             progress = TRUE) *10^-4)                           #pop per km2 (10^-6) and cell size is 10*10 m2. 

hu20 <- round(exact_extract(gis_hu20,
                             st_as_sf(gis_subbasins),
                             fun = "sum",
                             force_df = TRUE,
                             progress = TRUE) *10^-4)                           #HU per km2 (10^-6) and cell size is 10*10 m2. 

tbl_census20 <- data.frame(HUC12 = tbl_subbasins$HUC12, Pop = as.numeric(pop20), HU = as.numeric(hu20))
rm(pop20,hu20)

#1.4. Dominant eco-region & Deer density #######################################
################################################################################
tbl_ecoregion <- st_intersection(gis_subbasins,gis_ecoregion)%>%                #Get the dominant ecoregion by area
                          mutate(area = st_area(.))%>%
                          group_by(HUC12)%>%
                          filter(area == max(area))%>%
                          mutate(NA_L3KEY = paste(NA_L3CODE, NA_L3NAME))%>%
                          select(HUC12, NA_L3CODE, NA_L3KEY)
                      
tbl_ecoregion <- st_drop_geometry(tbl_ecoregion)
tbl_ecoregion <- tbl_ecoregion%>%                                               #Join deer density table by ecoregion
                        left_join(tbl_deer_dens, by = "NA_L3CODE")

#1.5. PRISM#####################################################################
################################################################################
precip <- exact_extract(gis_prism,
                             st_as_sf(gis_subbasins),
                             fun = "mean",
                             force_df = TRUE,
                             progress = TRUE)                                   #get mean precipitation for each HUC12
tbl_prism <- data.frame(HUC12 = tbl_subbasins$HUC12, PRCP = as.numeric(precip$mean))
rm(precip)

#1.6. Soil classes##############################################################
################################################################################



#1.7. 911 Addresses#############################################################
################################################################################


#1.8. NASS data#################################################################
################################################################################
nassqs_auth(key = "0E40870B-06A8-3D4C-83E3-112EAFC3CC02")
params <- list(source_desc = "CENSUS",                                          #Check for spaces and spelling errors
               sector_desc = "ANIMALS & PRODUCTS",
               group_desc = c("LIVESTOCK","SPECIALTY"),
               commodity_desc = c("CATTLE","SHEEP","GOATS","EQUINE"),
               statisticcat_desc = "INVENTORY",
               domain_desc = "TOTAL",
               short_desc = c("CATTLE, INCL CALVES - INVENTORY", 
                              "EQUINE, HORSES & PONIES - INVENTORY",
                              "GOATS - INVENTORY",
                              "SHEEP, INCL LAMBS - INVENTORY"),
               year = 2017,
               agg_level_desc = "COUNTY",
               state_alpha = c("OK","TX","NM","KS","CO","LA","AR"))
tbl_nass <- nassqs(params)
tbl_nass <- tbl_nass%>%
                mutate(GEOID = paste0(state_ansi,county_ansi))%>%
                select("state_alpha","commodity_desc","GEOID","county_name","Value")%>%
                pivot_wider(names_from = "commodity_desc", values_from = "Value")%>%
                mutate_all(~replace_na(., 0))
rm(params)

#1.9. CAFO data#################################################################
################################################################################


#1.10. WWTF#####################################################################
################################################################################
df <- echoWaterGetMeta()
tbl_facs_all <- echoWaterGetFacilityInfo(output = "df", 
                                p_huc = c("1108","1109","1110","1112","1113","1114",
                                          "1201","1202","1203","1204","1205","1206",
                                          "1207","1208","1209","1210","1211",
                                          "1304","1307","1308","1309","1305","1306"),
                                qcolumns = '1,14,23,24,25,26,197,204,290,308',
                                p_pstat = "EFF")

#Remove all facilities that are listed as follows in permit components (NA values will be filtered by other criteria)
tbl_facs_all <- tbl_facs_all%>%filter(!PermitComponents %in% c("Biosolids",
                                                               "CAFO",
                                                               "Construction Stormwater",
                                                               "Industrial Stormwater",
                                                               "Urban Stormwater (Small MS4)",
                                                               "Urban Stormwater (Medium/Large MS4)",
                                                               "Construction Stormwater, Industrial Stormwater"))
#Add a yes no column for selection
tbl_facs_all$include <- "No"

#All POTWs as Yes
tbl_facs_all$include[grepl(c("POTW"),tbl_facs_all$PermitComponents)] <- "Yes"

#All NA for POTW but with a Limpollutant bacteria
pollutants <- c("E. coli|Enterococci|Coliform, fecal general|Fecal coliform|Coliform, fecal|colony forming units|E. coli, colony forming units [CFU]|Coliform|total general")
tbl_facs_all$include[grepl(pollutants,tbl_facs_all$LimPollutant) & tbl_facs_all$include == "No"] <- "Yes"

#No previous criteria but contains WWTF or WWTP in name
tbl_facs_all$include[grepl(c("WWTF|WWTP|WASTEWATER TREATMENT"),tbl_facs_all$CWPName) & tbl_facs_all$include == "No"] <- "Yes"

#Remove some unwanted sites based on NPDES ID
#All LAG, ARG
tbl_facs_all <- tbl_facs_all%>%
                      filter(!str_starts(SourceID, "LAG"))%>%
                      filter(!str_starts(SourceID, "ARG"))

tbl_WWTF_facs <- tbl_facs_all%>%filter(include == "Yes")

#Add flow data
wwtf_flows <- list()
for(i in tbl_WWTF_facs$SourceID){
wwtf_flows[[i]] <- echoGetEffluent(p_id = i, 
                       parameter_code = 50050,
                       start_date = "01/01/2019",
                       end_date = "12/31/2023")

}
wwtf_flows <- do.call(bind_rows, wwtf_flows) 
length(unique(wwtf_flows$npdes_id))

wwtf_flows <- wwtf_flows%>%filter(statistical_base_type_desc == "Average")      #there are 70 LAG facs that dont have average but don't have value also, so doesn't matter

priority_order <- c("DAILY AV","ANNL AVG","MO AVG",
                    "7 DA AVG","30DA AVG","WKLY AVG")                           #other than daily or annual, other values are only one or same, do order for rest doesnt matter
df <- wwtf_flows%>%
          filter(limit_value_standard_units != "")%>%                           #standard units are always MGD
          mutate(limit_value_standard_units = as.numeric(limit_value_standard_units))%>%
          mutate(statistical_base_short_desc = factor(statistical_base_short_desc, levels = priority_order)) %>%
          group_by(npdes_id)%>%
          filter(monitoring_period_end_date == max(monitoring_period_end_date))%>%  #most recent monitoring date
          arrange(npdes_id, statistical_base_short_desc) %>%                    #if daily not available choose other average
          slice(1)%>%
          ungroup()%>%
          select(c("npdes_id","limit_value_standard_units"))

tbl_WWTF_facs <- tbl_WWTF_facs%>%
                          left_join(df, join_by("SourceID" == "npdes_id"))
tbl_WWTF_facs <- tbl_WWTF_facs%>%
                          mutate(limit_value_standard_units = if_else(is.na(limit_value_standard_units)|limit_value_standard_units == 0, CWPTotalDesignFlowNmbr, limit_value_standard_units))%>%
                          rename(Flow_MGD = limit_value_standard_units)%>%
                          mutate(Flow_MGD = if_else(is.na(Flow_MGD), 0, Flow_MGD))
rm(df)
#add Bacteria data
wwtf_ecoli <- list()
for(i in unique(tbl_WWTF_facs$SourceID)){
  wwtf_ecoli[[i]] <- echoGetEffluent(p_id = i, 
                              parameter_code = c(51040),
                              start_date = "01/01/2019",
                              end_date = "12/31/2023")
}
wwtf_ecoli <- do.call(bind_rows, wwtf_ecoli)

priority_order <- c("DAILY AV","GEO MEAN","30DAVGEO","SINGAMGE",
                    "DA GEOAV","MO AVG","WKLY AVG", "DA GEO")
df <- wwtf_ecoli%>%
        filter(statistical_base_type_desc == "Average")%>%
        filter(standard_unit_desc == "MPN/100mL")%>%
        mutate(statistical_base_short_desc = factor(statistical_base_short_desc, levels = priority_order)) %>%
        group_by(npdes_id)%>%
        filter(monitoring_period_end_date == max(monitoring_period_end_date))%>%
        arrange(npdes_id, statistical_base_short_desc) %>%                      #if daily not available choose other average
        slice(1)%>%
        ungroup()%>%
        mutate(Ecoli_MPN = as.numeric(limit_value_standard_units))%>%
        select(c("npdes_id","Ecoli_MPN"))

tbl_WWTF_facs <- tbl_WWTF_facs%>%
                    left_join(df,join_by(SourceID == npdes_id))%>%
                    mutate(Ecoli_MPN = ifelse(is.na(Ecoli_MPN), 126,Ecoli_MPN))%>% #all NA to 126
                    mutate(Ecoli_MPN = ifelse(Ecoli_MPN == 126000,126,Ecoli_MPN)) #correction 126000 to 126

#filter WWTFs in HUC12s
tbl_WWTF_facs <- tbl_WWTF_facs%>%
                  filter(FacDerivedWBD %in% tbl_subbasins$HUC12)

rm(df,pollutants)
#1.11 Write all RDATA###########################################################
################################################################################
save.image(file = "env_data.RData")
