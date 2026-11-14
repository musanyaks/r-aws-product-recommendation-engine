library(data.table)

# Retailrocket schema: events.csv = timestamp,visitorid,event,itemid,transactionid
# Timestamps are unix epoch *milliseconds*.
load_events <- function(dir = config$data_raw) {
  f <- file.path(dir, "events.csv")
  stopifnot("events.csv not found" = file.exists(f))
  dt <- fread(f)
  dt[, `:=`(visitorid = as.character(visitorid),
            itemid    = as.character(itemid))]
  dt[, timestamp := as.POSIXct(timestamp / 1000, origin = "1970-01-01", tz = "UTC")]
  dt[]
}

load_item_properties <- function(dir = config$data_raw) {
  files <- list.files(dir, pattern = "^item_properties.*\\.csv$", full.names = TRUE)
  if (!length(files)) return(NULL)
  dt <- rbindlist(lapply(files, fread))
  dt[, itemid := as.character(itemid)]
  setorder(dt, timestamp)
  dt[, .SD[.N], by = .(itemid, property)]   # latest value per item/property
}

load_category_tree <- function(dir = config$data_raw) {
  f <- file.path(dir, "category_tree.csv")
  if (file.exists(f)) fread(f) else NULL
}

library(data.table)

# Retailrocket schema: events.csv = timestamp,visitorid,event,itemid,transactionid
# Timestamps are unix epoch *milliseconds*.
load_events <- function(dir = config$data_raw) {
  f <- file.path(dir, "events.csv")
  stopifnot("events.csv not found" = file.exists(f))
  dt <- fread(f)
  dt[, `:=`(visitorid = as.character(visitorid),
            itemid    = as.character(itemid))]
  dt[, timestamp := as.POSIXct(timestamp / 1000, origin = "1970-01-01", tz = "UTC")]
  dt[]
}

load_item_properties <- function(dir = config$data_raw) {
  files <- list.files(dir, pattern = "^item_properties.*\\.csv$", full.names = TRUE)
  if (!length(files)) return(NULL)
  dt <- rbindlist(lapply(files, fread))
  dt[, itemid := as.character(itemid)]
  setorder(dt, timestamp)
  dt[, .SD[.N], by = .(itemid, property)]   # latest value per item/property
}

load_category_tree <- function(dir = config$data_raw) {
  f <- file.path(dir, "category_tree.csv")
  if (file.exists(f)) fread(f) else NULL
}