# Cosine similarity on demand: we never materialise the full item x item
# matrix (100k x 100k would not fit in memory). One row at a time is cheap.
similar_items <- function(model, item_id, n = 10) {
  item_id <- as.character(item_id)
  if (!item_id %in% model$item_index) return(data.table())
  i <- match(item_id, model$item_index)
  sims <- as.vector(model$content_feats[i, ] %*% t(model$content_feats))
  sims[i] <- -Inf
  top <- order(sims, decreasing = TRUE)[seq_len(min(n, length(sims)))]
  data.table(itemid = model$item_index[top],
             similarity = round(sims[top], 6),
             rank = seq_along(top))
}