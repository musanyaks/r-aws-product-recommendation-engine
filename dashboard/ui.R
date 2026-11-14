library(DT)
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Recommendation Engine"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview",          tabName = "overview",  icon = icon("gauge")),
      menuItem("Recommendations",   tabName = "recs",      icon = icon("wand-magic-sparkles")),
      menuItem("Catalog",           tabName = "catalog",   icon = icon("boxes-stacked")),
      menuItem("Model quality",     tabName = "quality",   icon = icon("chart-line")),
      menuItem("Live events",       tabName = "events",    icon = icon("bolt"))
    )
  ),

  dashboardBody(
    tags$head(tags$style(HTML("
      .small-box h3 { font-size: 28px; }
      .score-bar { font-family: monospace; }
    "))),

    tabItems(

      # ---------------- Overview ----------------
      tabItem("overview",
        fluidRow(
          valueBoxOutput("vb_users",   width = 3),
          valueBoxOutput("vb_items",   width = 3),
          valueBoxOutput("vb_inter",   width = 3),
          valueBoxOutput("vb_density", width = 3)
        ),
        fluidRow(
          box(title = "Top trending items (popularity)", width = 6, status = "primary",
              plotlyOutput("ov_pop", height = 350)),
          box(title = "Content feature coverage", width = 6, status = "primary",
              plotlyOutput("ov_feat", height = 350))
        ),
        fluidRow(
          box(title = "Loaded model", width = 12, status = "info",
              verbatimTextOutput("ov_model"))
        )
      ),

      # ---------------- Recommendations ----------------
      tabItem("recs",
        fluidRow(
          box(title = "Query", width = 3, status = "primary",
              textInput("rec_user", "Customer ID", value = ""),
              textInput("rec_recent", "Recent items (comma-sep, cold start)", value = ""),
              numericInput("rec_n", "How many", 10, 1, 50),
              actionButton("rec_go", "Recommend", class = "btn-primary", width = "100%"),
              hr(),
              verbatimTextOutput("rec_coldstart")
          ),
          box(title = "Recommendations", width = 9, status = "primary",
              DTOutput("rec_table"))
        ),
        fluidRow(
          box(title = "Score decomposition", width = 12, status = "info",
              plotlyOutput("rec_decomp", height = 320))
        )
      ),

      # ---------------- Catalog ----------------
      tabItem("catalog",
        fluidRow(
          box(title = "Find an item", width = 3, status = "primary",
              textInput("cat_item", "Item ID", value = ""),
              numericInput("cat_n", "Similar items", 10, 1, 50),
              actionButton("cat_go", "Find similar", class = "btn-primary", width = "100%")
          ),
          box(title = "Similar items (content-based)", width = 9, status = "primary",
              DTOutput("cat_table"))
        ),
        fluidRow(
          box(title = "Popularity distribution (all items)", width = 12, status = "info",
              plotlyOutput("cat_pophist", height = 300))
        )
      ),

      # ---------------- Model quality ----------------
      tabItem("quality",
        fluidRow(
          box(title = "Current model metrics", width = 6, status = "primary",
              DTOutput("q_metrics")),
          box(title = "vs popularity baseline", width = 6, status = "primary",
              plotlyOutput("q_vs_baseline", height = 280))
        ),
        fluidRow(
          box(title = "Metric distribution across evaluated users", width = 12, status = "info",
              selectInput("q_metric", "Metric",
                          choices = c("ndcg", "precision", "recall", "map"),
                          selected = "ndcg"),
              plotlyOutput("q_dist", height = 320))
        ),
        fluidRow(
          box(title = "Training history (model registry)", width = 12, status = "warning",
              DTOutput("q_registry"))
        )
      ),

      # ---------------- Live events ----------------
      tabItem("events",
        fluidRow(
          box(title = "Recent interactions (from /feedback)", width = 12, status = "primary",
              actionButton("ev_refresh", "Refresh", class = "btn-default"),
              DTOutput("ev_table"))
        ),
        fluidRow(
          box(title = "Events by type", width = 6, status = "info",
              plotlyOutput("ev_bytype", height = 300)),
          box(title = "Events over time", width = 6, status = "info",
              plotlyOutput("ev_overtime", height = 300))
        )
      )
    )
  )
)