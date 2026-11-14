library(shiny)

ui <- navbarPage("Recommendation Engine",
  tabPanel("Explorer",
    sidebarLayout(
      sidebarPanel(
        textInput("user", "Customer ID", ""),
        numericInput("n", "Recommendations", 10, 1, 50),
        actionButton("go", "Recommend")),
      mainPanel(tableOutput("recs"), plotOutput("recplot")))),
  tabPanel("Top products", plotOutput("popplot")),
  tabPanel("Model metrics", verbatimTextOutput("metrics")),
  tabPanel("Model registry", tableOutput("registry")))