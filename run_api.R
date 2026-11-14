suppressPackageStartupMessages(library(data.table))
for (f in c("utils", "config", "feature_engineering", "content_based",
            "hybrid_model", "db", "recommendation_service"))
  source(file.path("R", paste0(f, ".R")))

service$init()
plumber::plumb("api/plumber.R")$run(host = "0.0.0.0", port = config$port, swagger = TRUE)