# ---------------------------
# 0. LIBRARIES
# ---------------------------

library(sf)
library(RColorBrewer)
library(classInt)
library(rmapshaper)
library(tmap)
library(tmaptools)
library(cartogram)
library(ggplot2)
library(spdep)
library(spatialreg)
library(dplyr)
library(stargazer)
library(spgwr)
library(plotly)
library(scales)
library(car)
library(shinydashboard)
library(leaflet)


# ---------------------------
# 1. DATASETS
# ---------------------------


load("regioni.rda") #reg
load("dati_regioni_impianti_dash.rda") #full dataset aggregagated by region
load("dati_comuni_dash.rda") #full dataset with variables of interest
load("dataset_solar_energy.rda")
load("dataset_water_energy.rda")
load("dataset_wind_energy.rda")

# ---------------------------
# NOT USED
# ---------------------------


#load("aree_protette_2021_layer_reg.rda")
#load("aree_protette_2021_layer_com.rda")
#load("corine_sf_clean.rda")
#load("dataset_finale.rda") #dataset
#load("comuni.rda") #com


# ---------------------------
# 2. INTERACTIVE MAPS and PLOT-READY DATASETS
# --------------------------

load("windpower_maps_ready.rda") #windpower_maps(with municipalities that have at least 1 plant), colors_windpower (for plots)
load("solar_maps_ready.rda") #solar_maps (dataset with municipalities that have at least 1 plant), colori_solare(for plots),quantiles_log_solare (because distribution is skewed and the log facilitates plotting)
load("water_maps_ready.rda") #maps_idro (dataset with municipalities that have at least 1 plant), colors_water(for plots)
load("tmap_wind_interactive_number.rda")   # tm_wind_count
load("tmap_solar_interactive_number.rda")  # tm_solar_count
load("tmap_water_interactive_number.rda")  # tm_water_count



# ---------------------------
# 3. SPATIAL REGRESSIONS MODELS AND WEIGHTS
# ---------------------------

load("sdm_model_solar.rda") #sdm_model_wind, imp_sdm_wind
load("sdm_model_wind.rda") #sdm_model_solar, imp_sdm_solar
load("sdm_model_water.rda") #sdm_model_water, imp_sdm_water
load("queen_matrix.rda") #queen_neighbors_clean, queen_hybrid_weights_clean (weight matrix)



# ----------------------------------------
# 4. FUNCTION TO FIND NEIGHBOURS BASED ON USER'S INPUT
# ----------------------------------------
plot_queen_region <- function(region_name){
  
  regione <- dataset_solar_energy %>% filter(Nome_Regione == region_name) #or any other file with geometry
  regione$ID <- 1:nrow(regione)
  
  # Crea la Queen contiguity solo sulla regione filtrata
  neighbors_region <- poly2nb(regione, row.names = as.character(regione$ID), queen = TRUE, snap = 1000)
  
  # Conta i vicini
  count_region <- card(neighbors_region)
  
  # Se ci sono isole, collegale al nearest neighbor
  if(any(count_region == 0)){
    coords <- st_coordinates(st_centroid(regione))
    nnbs <- knearneigh(coords, k = 1)$nn
    no_edges <- which(count_region == 0)
    for(i in no_edges){
      neighbors_region[[i]] <- as.integer(nnbs[i])
    }
  }
  
  coords <- st_coordinates(st_centroid(regione))
  
  # Plot base
  plot(st_geometry(regione), border = "grey", main = paste("Queen contiguity -", region_name))
  
  # Disegna collegamenti
  plot(neighbors_region, coords, col = "blue", add = TRUE, lwd = 1)
  
  # Evidenzia isole collegate
  isole <- which(card(neighbors_region) == 1)
  if(length(isole) > 0){
    for(idx in isole){
      neighbor_id <- neighbors_region[[idx]]
      lines(x = c(coords[idx,1], coords[neighbor_id,1]),
            y = c(coords[idx,2], coords[neighbor_id,2]),
            col = "red", lwd = 2)
    }
  }
  
  legend("topright",
         legend = c("Queen contiguity", "Nearest neighbor (isole)"),
         col = c("blue", "red"),
         lwd = c(1,2))
}


# ----------------------------------------

