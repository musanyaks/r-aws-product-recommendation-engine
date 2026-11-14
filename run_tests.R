for (f in c("utils", "config", "feature_engineering", "content_based",
            "hybrid_model", "model_evaluation"))
  source(file.path("R", paste0(f, ".R")))
suppressPackageStartupMessages({ library(data.table); library(Matrix) })
testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)