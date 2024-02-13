loc_gis_data <- "./Input/GIS_TXSELECT_Feb2024/"
loc_tbl_data <- "./Input/tables/"

#Shapefiles
gis_subbasins    <- read_sf(paste0(loc_gis_data,"HAWQS_TXSELECT_demwshed.shp"))
gis_counties     <- read_sf(paste0(loc_gis_data,"Counties.shp"))
gis_CCN_UA       <- read_sf(paste0(loc_gis_data,"CCN_UA_Combined.shp"))
gis_ecoregion    <- read_sf(paste0(loc_gis_data,"ecoregions.shp"))
gis_911          <- read_sf(paste0(loc_gis_data,"addresses_NAD.shp"))
gis_coastal_ossf <-  read_sf(paste0(loc_gis_data,"coastal_OSSFs.shp"))
gis_ATTAINS_lines <- read_sf(paste0(loc_gis_data,"ATTAINS_LINES_HUC12_JOIN.shp"))
gis_ATTAINS_poly <- read_sf(paste0(loc_gis_data,"ATTAINS_POLY_HUC12_JOIN.shp"))

#Rasters
gis_ssurgo       <- terra::rast(paste0(loc_gis_data,"SSURGO_septic_class.tif"))    #30m septic tank absorption field- dominant conditions raster
gis_pop20        <-  terra::rast(paste0(loc_gis_data,"pop20.tif"))                    #10m POP density raster per km2
gis_hu20         <- terra::rast(paste0(loc_gis_data,"hu20.tif"))                      #10m HU density raster  per km2
gis_ossf_1990    <- terra::rast(paste0(loc_gis_data,"OSSF_1990.tif"))           #10m OSSF raster per km2
gis_nlcd         <- terra::rast(paste0(loc_gis_data,"nlcd2021.tif"))              #!Raster should only have value column. Delete all other columns
gis_prism        <- terra::rast(paste0(loc_gis_data,"prism.tif")) 

#Tables
tbl_deer_dens    <- read_csv(paste0(loc_tbl_data,"deer_densities.csv"))
tbl_cafo_data    <- read_csv(paste0(loc_tbl_data,"cafo_data_final.csv"))


load(file = "env_data.RData")
