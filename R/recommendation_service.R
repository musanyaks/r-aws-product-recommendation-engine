# recommendation_service.R
#
# Model lifecycle for the serving layer:
#   1. Locate the artifact (local file, real S3, or a local AWS emulator)
#   2. Load it into memory once at startup
#   3. Expose it to API handlers via the `service` environment
#
# Also provides upload_model_to_s3(), called by train.R to publish artifacts.

# ---------------------------------------------------------------------------
# service: mutable state for the running API process
# ---------------------------------------------------------------------------
service <- new.env()
service$model      <- NULL
service$model_id   <- NULL
service$started_at <- NULL

service$init <- function(model_file = config$model_file) {
  if (nzchar(config$model_s3_uri))
    model_file <- download_model_from_s3(config$model_s3_uri, config$model_dir)

  if (!file.exists(model_file))
    stop(sprintf(
      "Model artifact not found: %s\nRun train.R first, or set MODEL_S3_URI.",
      model_file))

  service$model      <- readRDS(model_file)
  service$model_id   <- service$model$model_id
  service$started_at <- Sys.time()

  message(sprintf("Model %s loaded (%d users x %d items)",
                  service$model_id,
                  length(service$model$user_index),
                  length(service$model$item_index)))
  invisible(TRUE)
}

# Reload the model without restarting the process — useful after a new
# artifact lands in S3. Wire to an admin endpoint if you want live updates.
service$reload <- function() service$init()

# ---------------------------------------------------------------------------
# S3 client: real AWS by default; floci/LocalStack when AWS_ENDPOINT_URL is set
# ---------------------------------------------------------------------------
s3_client <- function() {
  if (!nzchar(config$aws_endpoint))
    return(paws::s3())   # Real AWS: credentials resolved automatically
                         # (IAM task role on ECS, env vars or ~/.aws locally)

  # Emulator mode: dummy credentials + path-style addressing.
  # Emulators require path-style (bucket in the URL path); they can't do
  # virtual-hosted bucket names like real S3.
  paws::s3(config = list(
    endpoint            = config$aws_endpoint,
    region              = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1"),
    s3_force_path_style = TRUE,
    credentials = list(creds = list(
      access_key_id     = Sys.getenv("AWS_ACCESS_KEY_ID", "test"),
      secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY", "test")
    ))
  ))
}

# ---------------------------------------------------------------------------
# Artifact transfer
# ---------------------------------------------------------------------------
parse_s3_uri <- function(uri) {
  path <- sub("^s3://", "", uri)
  list(bucket = sub("/.*", "", path),
       key    = sub("^[^/]+/", "", path))
}

download_model_from_s3 <- function(uri, dest_dir = config$model_dir) {
  parts <- parse_s3_uri(uri)
  message(sprintf("Downloading model from %s ...", uri))
  obj <- s3_client()$get_object(Bucket = parts$bucket, Key = parts$key)
  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)
  dest <- file.path(dest_dir, basename(parts$key))
  writeBin(obj$Body, dest)
  message(sprintf("Model saved to %s (%.1f MB)", dest, file.size(dest) / 1e6))
  dest
}

upload_model_to_s3 <- function(file, uri) {
  parts <- parse_s3_uri(uri)
  s3_client()$put_object(Bucket = parts$bucket, Key = parts$key, Body = file)
  message(sprintf("Uploaded %s to %s", file, uri))
  invisible(uri)
}