# Score(u,i) = w_cf * CF(u,i) + w_cb * CB(u,i) + w_pop * POP(i), each rescaled
# to [0,1]. Components degrade gracefully: unknown user -> no CF term, no item
# history -> no CB term, brand-new session -> pure popularity (sensible default).
recommend_items <- function(model, user_id = NULL, recent_items = NULL, n = 10) {
  items <- model$item_index
  w <- model$weights
  cf <- cb <- NULL
  user_id <- as.character(user_id)
  seen_idx <- integer(0)

  if (length(user_id) == 1 && user_id %in% model$user_index) {
    u <- match(user_id, model$user_index)
    cf <- rescale01(as.vector(model$cf$P[u, ] %*% t(model$cf$Q)))
    seen_idx <- which(model$train_mat[u, ] > 0)
  }

  known_recent <- intersect(as.character(recent_items), items)
cb_basis <- unique(c(items[seen_idx], known_recent))
if (length(cb_basis) > 0) {
  b <- match(cb_basis, items)
  # only compute CB if the basis actually has features — else it rescales to flat 0.5
  if (any(Matrix::rowSums(model$content_feats[b, , drop = FALSE]) > 0)) {
    cb <- rescale01(as.vector(
      colMeans(model$content_feats[b, , drop = FALSE]) %*% t(model$content_feats)))
  }
}
  if (length(known_recent)) seen_idx <- unique(c(seen_idx, match(known_recent, items)))

  score <- 0; wsum <- 0
  if (!is.null(cf)) { score <- score + w$cf  * cf;  wsum <- wsum + w$cf }
  if (!is.null(cb)) { score <- score + w$cb  * cb;  wsum <- wsum + w$cb }
  score <- as.numeric(score + w$pop * model$popularity) / (wsum + w$pop)

  if (length(seen_idx)) score[seen_idx] <- -Inf   # never recommend what's owned
  top <- order(score, decreasing = TRUE)[seq_len(min(n, length(items)))]

  data.table(itemid = items[top],
             score = round(score[top], 6),
             cf    = if (!is.null(cf)) round(cf[top], 6) else NA_real_,
             cb    = if (!is.null(cb)) round(cb[top], 6) else NA_real_,
             popularity = round(model$popularity[top], 6))[, rank := .I][]
}