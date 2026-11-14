# Run from the repo root: shiny::runApp("dashboard")
library(shiny)
library(data.table)

root <- normalizePath(file.path(getwd(), ".."), mustWork = FALSE)
for (f in c("utils", "config", "hybrid_model", "db"))
  source(file.path(root, "R", paste0(f, ".R")))

model <- if (file.exists(file.path(root, "models", "model.rds")))
  readRDS(file.path(root, "models", "model.rds")) else NULL
con <- db_connect()

source("ui.R")
source("server.R")
shinyApp(ui, server)