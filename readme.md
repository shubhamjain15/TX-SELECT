TX-SELECT: A Web-Based Decision Support System for Regional Assessment
of Potential E. coli Loads Using a Spatially Explicit Modeling Approach
================
Shubham Jain

    ## [1] "Time of last build: 2024-03-13 16:03:18.974358"

**This project contains the R code for:** Jain, S.,Srinivasan R., Helton
T.J., and Karthikeyan R. (2024), TX-SELECT: A Web-Based Decision Support
System for Regional Assessment of Potential E. coli Loads Using a
Spatially Explicit Modeling Approach. ***Under Review***.

## Summary

TXSELECT (<https://tx.select.tamu.edu>), is a web-based Decision Support
System (DSS), which provides a user-friendly interface to run the SELECT
model on Texas watersheds. The DSS includes pre-determined watershed
specific inputs that can be readily adjusted within the interface based
on user preference and/or stakeholder recommendations, obviating the
necessity for expensive GIS tools and data extraction.

## Required data

Data required to reproduce the results is available at:
<https://doi.org/10.18738/T8/FWJVKW>

## File Descriptions

- `load_libraries.R`: Script to load all required packages to run other
  scripts.
- `load_data.R`: Script to load all GIS and tabular data required for
  analysis.
- `prep_data.R`: Script to prepare input data using GIS and other
  datasets.
- `create_TXSELECT_tables.R`: Script to prepare input tables for SELECT
  web tools containing default numbers.
- `estimate_loads.R`: scripts to estimate potential loads from all
  sources.
- `analysis.R`: Analysis codes for the TX-SELECT paper.
- `utils.R`: Required functions for plots.
- `plots_tables.R`: Codes for reproducible plots and tables in the
  TX-SELECT paper.
- `supplementary`: Codes for reproducible plots in the TX-SELECT
  supplementary materials. \## Instructions

To run the code, follow these steps:

1.  **Clone Repository**: Clone this GitHub repository to your local
    machine.

    ``` bash
    git clone https://github.com/shubhamjain15/TX-SELECT.git
    ```

2.  **Download data**: Download required data from: and save it within
    the current working directory.

3.  **Run R code**: Run R scripts in the order as listed in file
    descriptions.
