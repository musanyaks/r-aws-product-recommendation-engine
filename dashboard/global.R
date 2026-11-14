suppressPackageStartupMessages({
  library(shiny)
  library(bs4Dash)
  library(data.table)
  library(Matrix)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(scales)
  library(dplyr)
})

# Robustly find project root
find_root <- function() {
  path <- getwd()
  for (i in 1:5) {
    if (file.exists(file.path(path, "models", "model.rds"))) return(path)
    path <- dirname(path)
  }
  stop("Could not find models/model.rds")
}
root <- find_root()

# Load core functions
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "config.R"))
source(file.path(root, "R", "feature_engineering.R"))
source(file.path(root, "R", "hybrid_model.R"))
source(file.path(root, "R", "db.R"))

# Load model
model <- readRDS(file.path(root, "models", "model.rds"))

# Database connection (optional)
con <- db_connect()

# Catalog stats
catalog <- list(
  n_users  = length(model$user_index),
  n_items  = length(model$item_index),
  n_inter  = sum(model$train_mat > 0),
  density  = sum(model$train_mat > 0) / (length(model$user_index) * length(model$item_index)),
  n_feat   = sum(Matrix::rowSums(model$content_feats) > 0)
)


