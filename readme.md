TX-SELECT: A Web-Based Decision Support System for Regional Assessment
of Potential E. coli Loads Using a Spatially Explicit Modeling Approach
================
Shubham Jain

    ## [1] "Time of last build: 2024-03-14 15:09:19.726506"

**This project contains the R code for:** Jain, S., Srinivasan, R., Helton, T. J., & Karthikeyan, R. (2025). TXSELECT: a web-based decision support system for regional assessment of potential E. coli loads using a spatially explicit approach. Journal of Environmental Science and Health, Part A, 1–12. https://doi.org/10.1080/10934529.2024.2445953

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

- `run_file.R`: Step-by-step code to reproduce TXSELECT files and
  analysis.
- `load_libraries.R`: Load all required packages.
- `load_data.R`: Load all GIS and tabular data required for analysis.
- `prep_data.R`: Process raw GIS data files and datasets for TXSELECT
- `create_TXSELECT_tables.R`: Prepare TXSELECT predefined input tables
  in required format.
- `estimate_loads.R`: Estimate potential loads in all subwatersheds for
  manuscript analysis.
- `analysis.R`: Evaluating potential loads by subwatershed categories
- `utils.R`: Required functions for plots.
- `plots_tables.R`: Create plots and tables as shown in the manuscript.
- `supplementary`: Create plots and tables as shown in manuscript
  supplementary materials.

## Instructions

To run the code, follow these steps:

1.  **Clone Repository**: Clone this GitHub repository to your local
    machine.

    ``` bash
    git clone https://github.com/shubhamjain15/TX-SELECT.git
    ```

2.  **Download data**: Download required data from:
    <https://doi.org/10.18738/T8/FWJVKW> and save it within the current
    working directory in folder name “data”. All GIS data from the Texas
    Data Repository can be saved in the sub-folder “GIS” and all tables
    from GITHUB can be saved in the sub-folder “tables” to run the code
    directly.

3.  **Run R code**: Run R scripts in the order as listed in
    `run_file.R`.
