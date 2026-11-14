suppressPackageStartupMessages({ library(data.table); library(Matrix) })
for (f in c("utils", "config", "data_ingestion", "data_cleaning", "feature_engineering",
            "collaborative_filtering", "content_based", "hybrid_model",
            "model_evaluation", "db", "recommendation_service"))
  source(file.path("R", paste0(f, ".R")))

set.seed(42)
logf <- function(...) message(sprintf(...))

events <- load_events() |> clean_events()
props  <- load_item_properties()
logf("%d events | %d users | %d items",
     nrow(events), uniqueN(events$visitorid), uniqueN(events$itemid))

split  <- temporal_split(events, config$test_frac)
logf("Train %d events | Test %d events | cutoff %s",
     nrow(split$train), nrow(split$test), split$cutoff)
inter <- build_interactions(split$train, config$event_weights)
# keep users/items with enough signal for factorization
inter <- inter[, if (.N >= 2) .SD, by = visitorid]
inter <- inter[, if (.N >= 3) .SD, by = itemid]
mi <- build_rating_matrix(inter)

mi    <- build_rating_matrix(build_interactions(split$train, config$event_weights))
feats <- build_item_features(props, mi$items)
pop   <- compute_popularity(split$train, mi$items, config$event_weights, config$pop_tau_days)

logf("Training CF (dim=%d, niter=%d)...", config$cf$dim, config$cf$niter)
cf <- train_cf(mi, config$cf$dim, config$cf$niter, config$cf$lrate,
               config$cf$costp_l2, config$cf$costq_l2)

model <- list(
  model_id      = sprintf("hybrid-%s", format(Sys.time(), "%Y%m%d-%H%M%S")),
  created_at    = Sys.time(),
  cf            = cf,
  content_feats = feats,
  popularity    = pop,
  train_mat     = mi$mat,
  user_index    = mi$users,
  item_index    = mi$items,
  weights       = config$weights
)

test_rel <- relevant_items(split$test)
logf("Evaluating hybrid on %d test users...", length(test_rel))
model$metrics <- evaluate_model(model, test_rel, n = 10)

# Popularity-only baseline — the bar the hybrid must beat.
baseline <- model
baseline$weights <- list(cf = 0, cb = 0, pop = 1)
model$metrics$baseline_popularity <- evaluate_model(baseline, test_rel, n = 10)$mean

print(model$metrics$mean)
logf("Popularity baseline:"); print(model$metrics$baseline_popularity)

dir.create(config$model_dir, showWarnings = FALSE)
saveRDS(model, config$model_file)
logf("Model saved to %s", config$model_file)

if (nzchar(config$model_s3_uri)) {
  upload_model_to_s3(config$model_file, config$model_s3_uri)
  logf("Uploaded to %s", config$model_s3_uri)
}

con <- db_connect()
if (!is.null(con)) {
  db_register_model(con, model$model_id, "hybrid(cf+content+popularity)", model$metrics)
  DBI::dbDisconnect(con)
  logf("Model registered in database.")
}