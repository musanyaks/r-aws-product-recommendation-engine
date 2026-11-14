# dashboard/server.R

# Robustly find project root by locating model.rds
find_root <- function() {
  path <- getwd()
  for (i in 1:5) {
    if (file.exists(file.path(path, "models", "model.rds"))) return(path)
    path <- dirname(path)
  }
  stop("Could not find models/model.rds. Run from project root or a subdirectory.")
}
root <- find_root()

# Source core R files with absolute paths
source(file.path(root, "R", "utils.R"))
source(file.path(root, "R", "config.R"))
source(file.path(root, "R", "feature_engineering.R"))
source(file.path(root, "R", "hybrid_model.R"))
source(file.path(root, "R", "db.R"))

model <- readRDS(file.path(root, "models", "model.rds"))

con <- db_connect()

catalog <- list(
  n_users  = length(model$user_index),
  n_items  = length(model$item_index),
  n_inter  = sum(model$train_mat > 0),
  density  = sum(model$train_mat > 0) / (length(model$user_index) * length(model$item_index)),
  n_feat   = sum(Matrix::rowSums(model$content_feats) > 0)
)

# ---- The actual server logic ---------------------------------------------
server <- function(input, output, session) {

  # ---------- Overview ----------
  output$vb_users   <- renderValueBox(valueBox(
    format(catalog$n_users, big.mark = ","), "Users", icon = icon("users"), color = "blue"))
  
  # ... (all your render* blocks here) ...

  output$ev_overtime <- renderPlotly({
    req(ev_data())
    d <- ev_data()[, .N, by = .(minute = as.POSIXct(cut(occurred_at, "hour")))]
    p <- ggplot(d, aes(minute, N)) +
      geom_line(color = "#756bb1") + geom_point() +
      labs(x = NULL, y = "events") + theme_minimal()
    ggplotly(p)
  })
  
}  # ← Make sure this closing brace exists