# ui.R
library(shiny)
library(leaflet)
library(shinydashboard)
library(plotly) 



# ---------------------------
# UI
# ---------------------------
ui <- dashboardPage(
  dashboardHeader(
    title = 'SPATIAL DATA LAB - Exploration of Renewable Energy in Italy', 
    titleWidth = 800
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Description", tabName = "Descriptive", icon = icon("dashboard")),
      menuItem("Visualization", tabName = "Visual", icon = icon("map")),
      menuItem("Spatial Analysis", tabName = "Regression", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      # ---------------- Descriptive ----------------
      tabItem(
        tabName = "Descriptive",
        fluidRow(
          box(
            title = "How to use this section",
            width = 6,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            p(strong("Step 1:"), "Choose the level of analysis (Region or Municipality)."),
            p(strong("Step 2:"), "Select a specific region or municipality from the dropdown menu."),
            p(strong("Hint:"), "When Municipality is selected, you can search by typing the name."),
            p(em("All indicators below update automatically based on your selection."))
          ),
          box(title = "Legend",
              width = 6,
              status = "primary",
              background = "light-blue",
              solidHeader = TRUE,
              collapsible = TRUE,
              p(strong(" Boxes:"),"Each box shows the statistical profile for the region or municipality selected"),
              p(strong("Graphs:"), "The graphs below show the composition of renewable energy sources and the total power installed of each source for the selected region or municipality"),
              p(strong("Curiosity:"), "As you can see, although some regions have only a few wind power plants, wind energy still produces a large amount of total energy."),
          )
        ),
        fluidRow(
          box(
            title = "Select Level",
            solidHeader = TRUE,
            width = 6,
            status = "primary",
            radioButtons(
              inputId = "level_sel",
              label = "Select level of aggregation",
              choices = c("Region" = "region", "Municipality" = "comune"),
              selected = "region",
              inline = TRUE
            )
          ),
          box(
            title = "Select Region/Municipality",
            solidHeader = TRUE,
            width = 6,
            status = "primary",
            uiOutput("area_selector_ui")
          )
        ),
        fluidRow(
          valueBoxOutput("pop_box", width = 3),
          valueBoxOutput("dens_box", width = 3),
          valueBoxOutput("impianti_box", width = 3),
          valueBoxOutput("potenza_box", width = 3)
        ),
        fluidRow(
          box(
            title = "Energy Installations Composition",
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            plotlyOutput("impianti_pie")
          ),
          box(
            title = "Total Power by Type",
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            plotlyOutput("power_bar")
          )
        )
      ),
      
      # ---------------- Visualization ----------------
      tabItem(
        tabName = "Visual",
        fluidRow(
          box(
            title = "How to use this section",
            width = 6,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            p(strong("Step 1:"), "Choose the variable of interest (renewable energy) to load the interactve map"),
            p(strong("Step 2:"), "The map shows regional borders and each municipality is coloured based on the n. of installations"),
            p(strong("Note:"), "Click on the municipalit to display the number of installations and the total power in Kw")),
          box(
            title = "Select Energy Type",
            solidHeader = TRUE,
            width = 6,
            status = "primary",
            selectInput(
              inputId = "energy_type",
              label = "Energy type",
              choices = c("Wind", "Solar", "Hydro"),
              selected = "Wind"
            )
          ),
          fluidRow(
            box(title = "Installations of Renewable Energy Sources across the Italian country ",
                width = 12,
                tmapOutput("map_energy", height = 600)
            )
          )
        )
      ),
      # ---------------- Regression Analysis ----------------
      tabItem(
        tabName = "Regression",
        fluidRow(
          box(
            title = "How to use this section",
            width = 6,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            p(strong("Step 1:"), "Choose the dependent variable of interest."),
            p("Once selected, the spatial regression model will be estimated automatically."),
            p("The corresponding results and interpretation will be displayed below."),
            p(strong("Note:"),
              "The model accounts for spatial relationships between neighboring municipalities")
          ),
          box(
            title = "Model settings",
            width = 6,
            status = "primary",
            solidHeader = TRUE,
            
            selectInput(
              inputId = "dep_var",
              label = "Select dependent variable",
              choices = c(
                "Wind power plants" = "wind_installations",
                "Solar power plants" = "solar_installations",
                "Hydro power plants" = "hydro_installations"),
              selected = "solar_installations")
          )
        ),
        fluidRow(
          box(
            title = "Legend",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            withMathJax(
              p(
                "In a Spatial Durbin regression, the relationship between a dependent variable Y",
                " and a set of independent variables X also takes into account spatial interactions between neighboring areas.",
                "The model can be written as:"),
              p("$$ Y = \\alpha + \\rho W Y + \\beta X + \\theta W X + \\varepsilon $$"),
              p("where:"),
              tags$ul(
                tags$li("\\(\\alpha\\) is the intercept;"),
                tags$li("\\(WY\\) represents the influence of the dependent variable in neighboring areas;"),
                tags$li("\\(\\rho\\) measures how much nearby regions affect the value of \\(Y\\);"),
                tags$li("\\(X\\) is the vector of independent variables;"),
                tags$li("\\(WX\\) represents the values of those variables in neighboring areas;"),
                tags$li("\\(\\beta\\) and \\(\\theta\\) are vectors of coefficients associated with local and neighboring effects;"),
                tags$li("\\(\\varepsilon\\) is the error term, capturing the part of \\(Y\\) not explained by the model."),
                p(
                  "Each coefficient is tested to assess whether its effect is statistically significant. ",
                  "If the probability that a coefficient is equal to zero is lower than 5% ",
                  "(p\\text{-value} < 0.05), conventionally indicated by two asterisks ",
                  "(**), the effect is considered statistically significant."))
            )
          ),
          box(
            title = "Wind Energy Spatial Durbin Model",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            conditionalPanel(
              condition = "input.dep_var == 'wind_installations'",  # Mostra solo se selezionata wind_installations
              verbatimTextOutput("sdm_wind_results_summary"))
          ),
          box(
            title = "Solar Energy Spatial Durbin Model",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            conditionalPanel(
              condition = "input.dep_var == 'solar_installations'",  # Mostra solo se selezionata solar_installations
              verbatimTextOutput("sdm_solar_results_summary"))
          ),
          box(
            title = "Hydro Energy Spatial Durbin Model",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            conditionalPanel(
              condition = "input.dep_var == 'hydro_installations'",  # Mostra solo se selezionata hydroinstallations
              verbatimTextOutput("sdm_water_results_summary"))
          )
        ),
        fluidRow(
          box(
            title = "How to use this section",
            width = 6,
            status = "info",
            solidHeader = TRUE,
            collapsible = TRUE,
            p(strong("Select a region to focus on. Two maps will show ")),
            p(strong("First map:"),"Shows the spatial distribution of the selected dependent variable across municipalities."),
            p(strong("Second map:"), "Illustrates spatial relationships between municipalities, highlighting how nearby areas are connected.")
          ),
          box(
            title = "Select a Region",
            selectInput(
              inputId = "region_select",
              label = "Select a Region",
              choices = sort(unique(dataset$Nome_Regione)),
              selected = "Abruzzo")
          )
        ),
        fluidRow(
          box(
            title = "Spatial distribution",
            width = 6,
            plotOutput("map_installations1", height = 600) #the function is in the server
          ),
          box(
            title = "Spatial relationships",
            width = 6,
            plotOutput("queen_plot", height = 600) #the function is in the server
          )
        )
      )
    )
  )
)