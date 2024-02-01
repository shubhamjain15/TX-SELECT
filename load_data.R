loc_gis_data <- "./Input/GIS/"
loc_tbl_data <- "./Input/tables/"

gis_subbasins  <- read_sf(paste0(loc_gis_data,"HUC12_boundaries.shp"))%>%select("HUC12","NAME","TOHUC")
gis_counties   <- read_sf(paste0(loc_gis_data,"counties.shp"))
gis_urban_area <- read_sf(paste0(loc_gis_data,"urban_area_2020.shp"))
gis_ccn        <- read_sf(paste0(loc_gis_data,"texas_ccn.shp"))
gis_ssurgo    <- read_sf(paste0(loc_gis_data,"ssurgo.shp"))
gis_ecoregion  <- read_sf(paste0(loc_gis_data,"ecoregions_l3.shp"))
gis_911       <- read_sf(paste0(loc_gis_data,"addresses.shp"))
gis_prism      <- terra::rast(paste0(loc_gis_data,"PRISM.tif")) 
gis_pop20      <-  terra::rast(paste0(loc_gis_data,"pop20"))                    #10m POP density raster per km2
gis_hu20       <- terra::rast(paste0(loc_gis_data,"hu20"))                      #10m HU density raster  per km2
gis_ossf_1990 <- terra::rast(paste0(loc_gis_data,"census_1990.tif")) 
gis_nlcd       <- terra::rast(paste0(loc_gis_data,"nlcd_2019.tif"))             #Raster should only have value column. Delete all other columns

tbl_deer_dens  <- read_csv(paste0(loc_tbl_data,"deer_densities.csv"))