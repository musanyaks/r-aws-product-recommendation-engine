suppressPackageStartupMessages(library(data.table))
for (f in c("utils", "config", "feature_engineering", "content_based",
            "hybrid_model", "db", "recommendation_service"))
  source(file.path("R", paste0(f, ".R")))

service$init()

# Load handlers into an environment plumber will use
env <- new.env(parent = globalenv())
sys.source("api/endpoints.R", envir = env)

pr <- plumber::plumb("api/plumber.R", env = env)
pr$run(host = "0.0.0.0", port = config$port, swagger = TRUE)