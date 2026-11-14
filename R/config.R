# Central configuration. Everything is overridable via environment variables,
# which is how the same code runs locally and on ECS without modification.
config <- new.env()

config$data_raw       <- Sys.getenv("DATA_RAW", "data/raw")
config$model_dir      <- Sys.getenv("MODEL_DIR", "models")
config$model_file     <- file.path(config$model_dir, "model.rds")
config$model_s3_uri   <- Sys.getenv("MODEL_S3_URI", "")  # s3://bucket/models/model.rds

config$event_weights  <- c(view = 1, addtocart = 3, transaction = 5)
config$weights        <- list(cf = 0.5, cb = 0.3, pop = 0.2)
config$cf             <- list(dim = 32L, niter = 20L, lrate = 0.05,
                              costp_l2 = 0.01, costq_l2 = 0.01)
config$pop_tau_days   <- 30
config$test_frac      <- 0.15

config$db <- list(
  host     = Sys.getenv("DB_HOST", ""),
  port     = as.integer(Sys.getenv("DB_PORT", "5432")),
  dbname   <- Sys.getenv("DB_NAME", "reco"),
  user     <- Sys.getenv("DB_USER", "reco"),
  password <- Sys.getenv("DB_PASSWORD", "")
)

config$api_key <- Sys.getenv("API_KEY", "dev-key-change-me")
config$port    <- as.integer(Sys.getenv("PORT", "8000"))
config$aws_endpoint <- Sys.getenv("AWS_ENDPOINT_URL", "")  # floci/LocalStack endpoint