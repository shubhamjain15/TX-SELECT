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
# Step 2: Function to perform the Wilcoxon rank-sum test for a single value column and pair of groups
perform_wilcox_test <- function(df, value_column, group1, group2) {
  wilcox_result <- wilcox.test(
    as.numeric(unlist(df[df$Group == group1, value_column])),
    as.numeric(unlist(df[df$Group == group2, value_column])),conf.int = TRUE,
  )
  return(wilcox_result)
}

df <- final_load_hectares %>%
  select(c("Cattle","Equine","Goats_Sheep","Deer","Hogs","FailingOSSFs","WWTF","Pets","Total","Status","type"))%>%
  mutate(Group = paste0(Status,"_",type))%>%
  select(-c("Status","type"))

# Step 3: Perform the Wilcoxon rank-sum test for each value column and each pair of groups
value_columns <- names(df)[1:9] # Get columns starting with 'value'
group_combinations <- combn(unique(df$Group), 2, simplify = FALSE)

wilcox_results <- data.frame()
for (value_column in value_columns) {
  for (group_combination in group_combinations) {
    group1 <- group_combination[1]
    group2 <- group_combination[2]
    
    wilcox_result<- perform_wilcox_test(df, value_column, group1, group2)
    
    wilcox_results <- rbind(wilcox_results,data.frame(
      value_column = value_column,
      group1 = group1,
      group2 = group2,
      p_value = wilcox_result$p.value,
      loc_dif = wilcox_result$estimate
    ))
  }
}

h0_cannot_reject <- wilcox_results%>%
                        filter(p_value >= 0.05)

rm(value_column,value_columns,group_combination,group_combinations,group1,group2,p_value,df)
