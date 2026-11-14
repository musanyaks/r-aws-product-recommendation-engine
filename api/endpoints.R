# API handlers — plain functions, no plumber annotations, so they can be
# unit-tested directly (see tests/test_api.R). Loaded by run_api.R.

handle_health <- function() {
  list(status = "ok", model_id = service$model_id,
       uptime_seconds = as.numeric(difftime(Sys.time(), service$started_at, units = "secs")))
}

handle_recommendations <- function(user_id, n = 10, recent = "") {
  n <- suppressWarnings(as.integer(n)); if (is.na(n) || n < 1) n <- 10; n <- min(n, 100L)
  recent_items <- if (nzchar(recent)) strsplit(recent, ",")[[1]] else NULL
  list(user_id = user_id,
       model_id = service$model_id,
       cold_start = !user_id %in% service$model$user_index,
       recommendations = recommend_items(service$model, user_id, recent_items, n))
}
handle_similar <- function(item_id, n = 10) {
  n <- as.integer(n); if (is.na(n) || n < 1) n <- 10
  list(item_id = item_id, similar = similar_items(service$model, item_id, n))
}

handle_popular <- function(n = 10) {
  n <- as.integer(n); if (is.na(n) || n < 1) n <- 10
  pop <- service$model$popularity
  top <- order(pop, decreasing = TRUE)[seq_len(min(n, length(pop)))]
  list(popular = data.table(itemid = service$model$item_index[top],
                            score = round(pop[top], 6)))
}

handle_feedback <- function(req, res) {
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
  if (is.null(body$user_id) || is.null(body$item_id) || is.null(body$event)) {
    res$status <- 400L
    return(list(error = "user_id, item_id and event are required"))
  }
  con <- db_connect()
  if (is.null(con)) { res$status <- 503L; return(list(error = "database not configured")) }
  on.exit(DBI::dbDisconnect(con))
  db_insert_event(con, body$user_id, body$item_id, body$event)
  list(status = "recorded")
}