# Spatial Econometric Analysis of Renewable Energy Plants in Italy
#[https://francescavasta.shinyapps.io/spatial_eco_renewable_energy_dash/]

## Introduction

This research project aims to analyze the territorial distribution of renewable energy plants (solar, wind, hydroelectric) across the Italian territory using spatial econometric methodologies.

### Research Objectives

The main objectives are to:
- Identify territorial, demographic, and environmental factors influencing the location of renewable energy plants
- Analyze spatial correlations and concentration/dispersion patterns of plants across the national territory
- Quantify the impact of different territorial characteristics on installed capacity by plant type
- Provide empirical evidence to support sustainable development and energy transition policies

## Data Sources and Dataset
The project integrates multiple official data sources to build a comprehensive dataset at municipal and regional levels:

### 1. Administrative Baseline Data
**Regional and Municipal Administrative Boundaries**
- Source: Official Italian territorial databases
- Usage: Geographic foundation for spatial regression analysis

### 2. Energy Plant Data
**Plant Location and Capacity (2021)**
- Source: [GSE Plants Atlas](https://atla.gse.it/atlaimpianti/project/Atlaimpianti_Internet.html)
- Content: Municipal location of solar, hydroelectric, and wind plants with respective capacities
- Format: Excel files with municipal, provincial, and regional codes
- Usage: Main dependent variable for regression analysis

### 3. Land Use Data
**Corine Land Cover 2021 (Level IV)**
- Source: Official Corine Land Cover database
- Format: Shapefile
- Usage: Primarily for cartographic visualizations

**Land Use Indicators 2021** 
- Source: ISPRA (Italian Institute for Environmental Protection and Research)
- Content: ~130 land use indicators at municipal level
- Format: Excel with territorial codes
- Usage: Explanatory variables for regression analysis

### 4. Protected Areas
**Italian Protected Areas Database**
- Source: EEA (European Environment Agency)
- Content: Shapefiles of protected areas (Natura 2000 and other designations)
- Main files: `N2000_spatial_IT_2024_12_15_region_WGS_1984`, `Natura2000_end2021_rev1`
- Usage: Primarily for cartographic visualizations

### 5. Regional Indicators 
**National Indicators Archive**
- Content: >600 demographic, economic, political, and environmental indicators at regional level
- Categories: Business R&D, electricity service quality, transport, environment
- Usage: Control variables for regression analysis

### 6. Feature Engineering
New derived variables have been created to capture aspects not directly available in the original datasets (for isntance: proportions of territory allocated to renewable energy)

DISCLAIMER: The most updated and comprehensive data I found were those referring to the year 2021. While some datasets extend to 2024 (land use indicators), the core renewable energy plant data represents the 2021 snapshot, which serves as the primary reference year for this analysis.

## Dataset Structure

The final dataset integrates information at both **municipal** and **regional** levels, enabling multi-level analysis. 
The richness of collected variables allows for:

1. **Spatial regression analysis** with comprehensive set of explanatory variables
2. **Thematic cartography** for visualization of territorial patterns
3. **Comparative descriptive statistics** across Italian regions

## Project Status

This project is currently under development

---

*Work in progress - Last updated: 3rd 2025*
