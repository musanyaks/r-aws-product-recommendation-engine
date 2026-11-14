ui <- dashboardPage(
  title = "Recommendation Engine",
  dark = TRUE,
  help = NULL,
  
  header = dashboardHeader(
    title = dashboardBrand(
      title = "Recommendation Engine",
      color = "primary",
      href = "#",
      image = NULL
    ),
    skin = "dark",
    status = "white"
  ),
  
  sidebar = dashboardSidebar(
    skin = "dark",
    status = "primary",
    title = "Navigation",
    elevation = 3,
    
    sidebarMenu(
      id = "tabs",
      menuItem("Overview",       tabName = "overview", icon = icon("gauge-high")),
      menuItem("Recommendations", tabName = "recs",     icon = icon("wand-magic-sparkles")),
      menuItem("Catalog",        tabName = "catalog",  icon = icon("boxes-stacked")),
      menuItem("Model Quality",  tabName = "quality",  icon = icon("chart-line")),
      menuItem("Live Events",    tabName = "events",   icon = icon("bolt"))
    )
  ),
  
  body = dashboardBody(
    tabItems(
      
      # ============== Overview ==============
      tabItem("overview",
        fluidRow(
          valueBoxOutput("vb_users",   width = 3),
          valueBoxOutput("vb_items",   width = 3),
          valueBoxOutput("vb_inter",   width = 3),
          valueBoxOutput("vb_density", width = 3)
        ),
        
        fluidRow(
          bs4Card(
            title = "Top Trending Items",
            width = 6,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("ov_pop", height = 400)
          ),
          bs4Card(
            title = "Content Feature Coverage",
            width = 6,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("ov_feat", height = 400)
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Model Information",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            verbatimTextOutput("ov_model")
          )
        )
      ),
      
      # ============== Recommendations ==============
      tabItem("recs",
        fluidRow(
          bs4Card(
            title = "Query Parameters",
            width = 3,
            elevation = 2,
            closable = FALSE,
            textInput("rec_user", "Customer ID", value = ""),
            textInput("rec_recent", "Recent Items (comma-separated, for cold start)", value = ""),
            numericInput("rec_n", "Number of Recommendations", 10, 1, 50),
            actionButton("rec_go", "Get Recommendations", class = "btn-primary", width = "100%"),
            hr(),
            verbatimTextOutput("rec_coldstart")
          ),
          
          bs4Card(
            title = "Recommendations",
            width = 9,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            DTOutput("rec_table")
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Score Decomposition",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("rec_decomp", height = 350)
          )
        )
      ),
      
      # ============== Catalog ==============
      tabItem("catalog",
        fluidRow(
          bs4Card(
            title = "Find Similar Items",
            width = 3,
            elevation = 2,
            closable = FALSE,
            textInput("cat_item", "Item ID", value = ""),
            numericInput("cat_n", "Number of Similar Items", 10, 1, 50),
            actionButton("cat_go", "Find Similar", class = "btn-primary", width = "100%")
          ),
          
          bs4Card(
            title = "Similar Items (Content-Based)",
            width = 9,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            DTOutput("cat_table")
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Popularity Distribution",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("cat_pophist", height = 350)
          )
        )
      ),
      
      # ============== Model Quality ==============
      tabItem("quality",
        fluidRow(
          bs4Card(
            title = "Current Model Metrics",
            width = 6,
            elevation = 2,
            closable = FALSE,
            DTOutput("q_metrics")
          ),
          
          bs4Card(
            title = "Hybrid vs Popularity Baseline",
            width = 6,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("q_vs_baseline", height = 300)
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Metric Distribution Across Users",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            selectInput("q_metric", "Select Metric",
                        choices = c("NDCG" = "ndcg", "Precision" = "precision",
                                   "Recall" = "recall", "MAP" = "map"),
                        selected = "ndcg"),
            plotlyOutput("q_dist", height = 350)
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Model Training History",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            DTOutput("q_registry")
          )
        )
      ),
      
      # ============== Live Events ==============
      tabItem("events",
        fluidRow(
          bs4Card(
            title = "Recent Interactions",
            width = 12,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            actionButton("ev_refresh", "Refresh", class = "btn-secondary"),
            hr(),
            DTOutput("ev_table")
          )
        ),
        
        fluidRow(
          bs4Card(
            title = "Events by Type",
            width = 6,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("ev_bytype", height = 300)
          ),
          
          bs4Card(
            title = "Events Over Time",
            width = 6,
            elevation = 2,
            closable = FALSE,
            maximizable = TRUE,
            plotlyOutput("ev_overtime", height = 300)
          )
        )
      )
    )
  ),
  
  footer = dashboardFooter(
    left = "Recommendation Engine v1.0",
    right = format(Sys.Date(), "%Y")
  )
)