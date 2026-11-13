library(Matrix)

# Implicit feedback: sum weighted events per (user, item), log-dampen.
build_interactions <- function(events, event_weights) {
  events[, w := as.numeric(event_weights[event])]
  inter <- events[, .(weight = sum(w), last_ts = max(timestamp)), by = .(visitorid, itemid)]
  inter[, rating := log1p(weight)]
  inter[]
}

# Temporal split — never split interactions randomly for recommenders;
# you'd leak future behaviour into training.
temporal_split <- function(events, test_frac = 0.15) {
  cutoff <- as.POSIXct(quantile(as.numeric(events$timestamp), 1 - test_frac),
                       origin = "1970-01-01", tz = "UTC")
  list(train = events[timestamp < cutoff],
       test  = events[timestamp >= cutoff],
       cutoff = cutoff)
}

build_rating_matrix <- function(interactions) {
  users <- sort(unique(interactions$visitorid))
  items <- sort(unique(interactions$itemid))
  ui <- match(interactions$visitorid, users)
  ii <- match(interactions$itemid, items)
  mat <- sparseMatrix(i = ui, j = ii, x = interactions$rating,
                      dims = c(length(users), length(items)), repr = "C")
  list(mat = mat, users = users, items = items,
       ui = ui, ii = ii, x = interactions$rating)
}

# Content features: one-hot tokens "property=value" (categoryid + hashed props),
# IDF-weighted, rows L2-normalized so row i . row j = cosine similarity.
build_item_features <- function(item_properties, items, max_tokens = 5000L) {
  if (is.null(item_properties) || !nrow(item_properties)) {
    return(sparseMatrix(integer(0), integer(0), x = numeric(0),
                        dims = c(length(items), 1)))
  }
  tok <- unique(item_properties[, .(itemid, token = paste(property, value, sep = "="))])
  tok <- tok[itemid %in% items]
  keep <- tok[, .N, by = token][order(-N)][seq_len(min(.N, max_tokens)), token]
  tok  <- tok[token %in% keep]
  feats <- sort(unique(tok$token))
  F <- sparseMatrix(i = match(tok$itemid, items), j = match(tok$token, feats), x = 1,
                    dims = c(length(items), length(feats)), repr = "C")
  idf <- log(nrow(F) / (1 + colSums(F > 0)))
  F <- F %*% Diagonal(x = idf)
  F / sqrt(pmax(rowSums(F^2), 1e-12))
}

# Time-decayed, log-scaled popularity, normalized to [0,1], aligned to `items`.
compute_popularity <- function(events, items, event_weights, tau_days = 30) {
  events[, w := as.numeric(event_weights[event])]
  ref <- max(events$timestamp)
  events[, decay := exp(-as.numeric(difftime(ref, timestamp, units = "days")) / tau_days)]
  pop <- events[, .(pop = sum(w * decay)), by = itemid]
  pop[, pop := rescale01(log1p(pop))]
  out <- numeric(length(items))
  m <- match(pop$itemid, items)
  ok <- !is.na(m)
  out[m[ok]] <- pop$pop[ok]
  out
}

# Ground truth for evaluation: items each user transacted/carted in the test window.
relevant_items <- function(test_events) {
  rel <- test_events[event %in% c("transaction", "addtocart"),
                     .(items = list(unique(itemid))), by = visitorid]
  setNames(rel$items, rel$visitorid)
}