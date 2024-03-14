#1. Load libraries
source("load_libraries.R")

#2. Load required data
loc_gis_data <- "./data/GIS/"  #Save all GIS data files in this folder
loc_tbl_data <- "./data/tables/" #Save all required tables in this folder
source("load_data")

#3. Prepare data 
source("prep_data.R")

#4. Create input tables for TXSELECT
source("create_TXSELECT_tables.R")

#5. Estimate potential loads in all HUC12 subwatersheds
source("estimate_loads.R")

#6. Analysis for manuscript results
source("analysis.R")

#7. Some utility functions required for plotting 
source("utils.R")

#8. Plot figures and tables
source("plots_tables.R")

#9. Plots and figures for supplementary information
source("supplementary.R")
