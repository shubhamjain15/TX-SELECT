TX-SELECT:A Web-Based Decision Support System for Regional Assessment of
Potential E. coli Loads Using a Spatially Explicit Modeling Approach
================
Shubham Jain

    ## [1] "Time of last build: 2024-02-21 13:57:46.278369"

This project contains the R code for: Jain, S.,Srinivasan R., Helton
T.J., and Karthikeyan R. (2024), TX-SELECT:A Web-Based Decision Support
System for Regional Assessment of Potential E. coli Loads Using a
Spatially Explicit Modeling Approach

## Summary

We developed a web-based Decision Support System (DSS), TXSELECT, which
provides a user-friendly interface to run the SELECT model on Texas
watersheds. The DSS includes pre-determined watershed specific inputs
that can be readily adjusted within the interface based on user
preference and/or stakeholder recommendations, obviating the necessity
for expensive GIS tools and data extraction.

\##Download data Download data required to reproduce the results from:

## File Descriptions

- `load_libraries.R`: Script to load all required packages to run other
  scripts.
- `prep_data.R`: Script to prepare input data using GIS and other
  datasets.
- `SELECT_counts.R`: Script to prepare input tables for SELECT web tools
  containing default numbers.
- `analysis.R`: Analysis codes for the TX-SELECT paper.
- `plots.R`: Codes for reproducible plots in the TX-SELECT paper.

## Instructions

To run the code, follow these steps:

1.  **Clone Repository**: Clone this GitHub repository to your local
    machine.

    \`\`\`bash git clone
    <https://github.com/shubhamjain15/TX-SELECT.git>
