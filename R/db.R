db_connect <- function() {
  if (!nzchar(config$db$host)) return(NULL)   # DB optional; graceful without it
  DBI::dbConnect(RPostgres::Postgres(),
                 host = config$db$host, port = config$db$port,
                 dbname = config$db$dbname, user = config$db$user,
                 password = config$db$password)
}

db_insert_event <- function(con, visitorid, itemid, event_type) {
  DBI::dbExecute(con,
    "INSERT INTO interactions (customer_id, product_id, event_type, occurred_at)
     VALUES ($1, $2, $3, NOW())",
    params = list(as.character(visitorid), as.character(itemid), event_type))
}

db_register_model <- function(con, model_id, algorithm, metrics) {
  DBI::dbExecute(con,
    "INSERT INTO model_registry (model_id, algorithm, metrics, trained_at)
     VALUES ($1, $2, $3::jsonb, NOW())",
    params = list(model_id, algorithm, jsonlite::toJSON(metrics$mean, auto_unbox = TRUE)))
}