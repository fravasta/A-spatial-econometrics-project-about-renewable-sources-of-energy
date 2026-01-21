
# ---------------------------
# Server
# ---------------------------
server <- function(input, output, session) {
  
  #------------------------- Descriptive ----------------------------
  
  # --------------------------
  # User input and filter
  # --------------------------
  
  # UI dinamico per selezione area
  output$area_selector_ui <- renderUI({
    if (input$level_sel == "region") {
      
      selectInput(
        inputId = "area_sel",
        label = "Select Region",
        choices = sort(unique(dati_regioni_impianti_dash$Nome_Regione)),
        selected = "Lombardia"
      )
      
    } else {
      
      selectizeInput(
        inputId = "area_sel",
        label = "Select Municipality",
        choices = sort(unique(dati_comuni_dash$COMUNE)),
        selected = "Roma",
        options = list(
          placeholder = "Type municipality name...",
          maxOptions = 10
        )
      )
      
    }
  })
  
  # Filtra i dati in base alla selezione
  selected_data <- reactive({
    if(input$level_sel == "region"){
      dati_regioni_impianti_dash %>% filter(Nome_Regione == input$area_sel)
    } else {
      dati_comuni_dash %>% filter(COMUNE == input$area_sel)
    }
  })
  
  # --------------------------
  # Value Boxes
  # --------------------------
  output$pop_box <- renderValueBox({
    df <- selected_data()
    
    valueBox(
      value = prettyNum(
        if (input$level_sel == "region")
          df$popolazione_tot
        else
          df$Popolazione,
        big.mark = ","
      ),
      subtitle = "Population",
      icon = icon("users"),
      color = "purple"
    )
  })
  
  
  output$dens_box <- renderValueBox({
    df <- selected_data()
    
    valueBox(
      value = round(
        if (input$level_sel == "region")
          df$densita_popolazione
        else
          df$Densità,
        1
      ),
      subtitle = "Population Density (per km²)",
      icon = icon("chart-area"),
      color = "blue"
    )
  })
  
  
  output$impianti_box <- renderValueBox({
    df <- selected_data()
    
    tot <- if (input$level_sel == "region") {
      df$n_impianti_sol + df$n_impianti_eol + df$n_impianti_idro
    } else {
      df$n_installations_SOLARE +
        df$n_installations_EOLICA +
        df$n_installations_IDRAULICA
    }
    
    valueBox(
      value = tot,
      subtitle = "Total Installations",
      icon = icon("bolt"),
      color = "yellow"
    )
  })
  
  
  output$potenza_box <- renderValueBox({
    df <- selected_data()
    
    tot <- if (input$level_sel == "region") {
      df$potenza_sol_tot + df$potenza_eol_tot + df$potenza_idro_tot
    } else {
      df$total_power_SOLARE +
        df$total_power_EOLICA +
        df$total_power_IDRAULICA
    }
    
    valueBox(
      value = prettyNum(tot, big.mark = ","),
      subtitle = "Total Power (kW)",
      icon = icon("battery-full"),
      color = "green"
    )
  })
  
  
  # --------------------------
  # Pie chart 
  # --------------------------
  output$impianti_pie <- renderPlotly({
    df <- selected_data()
    
    values <- if (input$level_sel == "region") {
      c(df$n_impianti_sol, df$n_impianti_eol, df$n_impianti_idro)
    } else {
      c(
        df$n_installations_SOLARE,
        df$n_installations_EOLICA,
        df$n_installations_IDRAULICA
      )
    }
    
    plot_ly(
      labels = c("Solar", "Wind", "Hydro"),
      values = values,
      type = "pie",
      textinfo = "label+percent"
    )
  })
  
  # --------------------------
  # Bar chart (total power installed)
  # --------------------------
  output$power_bar <- renderPlotly({
    df <- selected_data()
    
    values <- if (input$level_sel == "region") {
      c(df$potenza_sol_tot, df$potenza_eol_tot, df$potenza_idro_tot)
    } else {
      c(
        df$total_power_SOLARE,
        df$total_power_EOLICA,
        df$total_power_IDRAULICA
      )
    }
    
    plot_ly(
      x = c("Solar", "Wind", "Hydro"),
      y = values,
      type = "bar",
      marker = list(color = c("gold", "darkgreen", "dodgerblue"))
    ) %>%
      layout(yaxis = list(title = "Total Power (kW)"))
  })
  
  
  #------------------------- Visualization ----------------------------
  
  # --------------------------
  # Interactive Tmap loaded based on user's choice
  # --------------------------
  
  
  output$map_energy <- renderTmap({
    req(input$energy_type)  #input is required
    map_selected <- switch(input$energy_type,
                           "Wind"  = tm_wind_count,
                           "Solar" = tm_solar_count,
                           "Hydro" = tm_water_count)
    
    map_selected
  })
  
  #------------------------- Visualization ----------------------------
  
  # --------------------------
  # Spatial Durbin Model Summary
  # --------------------------
  # for plotting model results based on dependent variable chosen
  
  output$sdm_wind_results_summary <- renderPrint({
    req(input$dep_var == "wind_installations")   # Attende che l'utente selezioni Wind
    
    # load the model
    load("sdm_model_wind.rda")   # carica sdm_model_wind e imp_sdm_wind
    
    # Show
    summary(sdm_model_wind)
    
    # per stampare le importanze o effetti marginali
    # print(imp_sdm_wind)
  })
  
  
  output$sdm_solar_results_summary <- renderPrint({
    req(input$dep_var == "solar_installations")   # Attende che l'utente selezioni Solar
    
    # Carica il modello salvato
    load("sdm_model_solar.rda")   # carica sdm_model_solar e imp_sdm_solar
    
    # Mostra il summary del modello
    summary(sdm_model_solar)
    
    # per  stampare le importanze o effetti marginali
    # print(imp_sdm_wind)
  })
  
  output$sdm_water_results_summary <- renderPrint({
    req(input$dep_var == "hydro_installations")   # Attende che l'utente selezioni Hydro
    
    # Carica il modello salvato
    load("sdm_model_water.rda")   # carica sdm_model_water e imp_sdm_water
    
    # Mostra il summary del modello
    summary(sdm_model_water)
    
    # per  stampare le importanze o effetti marginali
    # print(imp_sdm_wind)
  })

  
  
  # --------------------------
  # Static Map of Plants Distribution across the italian country  (Regional focus)
  # --------------------------
  
  output$map_installations1 <- renderPlot({
    
    req(input$region_select, input$dep_var)  # input coerente
    
    # --- Seleziona dataset ---
    data_selected <- switch(input$dep_var,
                            "wind_installations"  = list(
                              data = windpower_maps,
                              var  = "n_installations_EOLICA",
                              colors = c("lightgreen","lightseagreen","mediumseagreen","forestgreen","darkgreen"),
                              title = "Geographical Distribution of Windpower plants",
                              subtitle = "Overview of the number of Windpower plants for each municipality"
                            ),
                            "solar_installations" = list(
                              data = solar_maps,
                              var  = "n_installations_SOLARE",
                              colors = c("lightyellow","navy","darkmagenta","mediumorchid","mediumvioletred","darkorange","yellow"),
                              title = "Distribution of Solar plants",
                              subtitle = "Number of solar plants installed for each municipality"
                            ),
                            "hydro_installations" = list(
                              data = maps_idro,
                              var  = "n_installations_IDRAULICA",
                              colors = c("white","lightblue","skyblue","dodgerblue","blue"),
                              title = "Distribution of Hydro electric plants",
                              subtitle = "Number of hydro electric plants for each municipality"
                            ))
    
    # --- Filter the region selected by the user ---
    data_region <- data_selected$data %>% filter(Nome_Regione == input$region_select)
    req(nrow(data_region) > 0)
    
    # --- Mappa ggplot ---
    ggplot() +
      geom_sf(data = reg %>% filter(DEN_REG == input$region_select),
              fill = NA, color = "black", size = 0.4) +
      geom_sf(data = data_region,
              aes(fill = .data[[data_selected$var]]),
              color = NA) +
      scale_fill_gradientn(colors = data_selected$colors, 
                           na.value = "white",
                           name = paste("Num", input$dep_var)) +
      theme_minimal() +
      labs(
        title = paste(data_selected$title, "in", input$region_select),
        caption = "Source: Atlante degli impianti del GSE"
      ) +
      theme(
        legend.position = "right",
        plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(size = 11)
      )
    })
    
  
  
  ## for plotting neighbours
  output$queen_plot <- renderPlot({
    req(input$region_select)  # input dalla selectInput con le regioni
    plot_queen_region(input$region_select)
  }) 
}

# ---------------------------
# Run the app
# ---------------------------
shinyApp(ui = ui, server = server)
