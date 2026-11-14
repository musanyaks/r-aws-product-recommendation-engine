suppressPackageStartupMessages({
  library(shiny); library(shinydashboard); library(data.table)
  library(Matrix); library(ggplot2); library(DT); library(plotly); library(scales)
})

# Find project root and set it as working directory
find_root <- function() {
  path <- getwd()
  for (i in 1:5) {
    if (file.exists(file.path(path, "models", "model.rds"))) return(path)
    path <- dirname(path)
  }
  stop("Could not find models/model.rds")
}
setwd(find_root())

source("dashboard/ui.R")
source("dashboard/server.R")
shinyApp(ui, server)