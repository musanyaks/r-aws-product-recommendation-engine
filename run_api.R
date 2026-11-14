suppressPackageStartupMessages(library(data.table))
for (f in c("utils", "config", "feature_engineering", "content_based",
            "hybrid_model", "db", "recommendation_service"))
  source(file.path("R", paste0(f, ".R")))
source("api/endpoints.R")

service$init()

pr <- plumber::Plumber$new()

# Auth filter: API key on everything except health/docs
pr$filter("auth", function(req, res) {
  public <- c("/health", "/__docs__/", "/openapi.json")
  if (any(startsWith(req$PATH_INFO, public))) return(plumber::forward())
  if (!identical(req$HTTP_X_API_KEY, config$api_key)) {
    res$status <- 401L
    return(list(error = "missing or invalid API key"))
  }
  plumber::forward()
})

pr$handle("GET", "/health", function() handle_health())

pr$handle("GET", "/recommendations/<user_id>",
          function(user_id, n = 10, recent = "") handle_recommendations(user_id, n, recent))

pr$handle("GET", "/similar/<item_id>",
          function(item_id, n = 10) handle_similar(item_id, n))

pr$handle("GET", "/popular",
          function(n = 10) handle_popular(n))

pr$handle("POST", "/feedback",
          function(req, res) handle_feedback(req, res))

pr$run(host = "0.0.0.0", port = config$port, swagger = TRUE)