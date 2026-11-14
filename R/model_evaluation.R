precision_at_k <- function(rec, rel, k = 10) {
  if (!length(rec)) return(0)
  length(intersect(head(rec, k), rel)) / k
}

recall_at_k <- function(rec, rel, k = 10) {
  if (!length(rel)) return(0)
  length(intersect(head(rec, k), rel)) / length(rel)
}

ap_at_k <- function(rec, rel, k = 10) {
  rec <- head(rec, k)
  hits <- which(rec %in% rel)
  if (!length(hits)) return(0)
  sum(vapply(hits, function(h) length(intersect(head(rec, h), rel)) / h,
             numeric(1))) / min(length(rel), k)
}

ndcg_at_k <- function(rec, rel, k = 10) {
  rec <- head(rec, k)
  dcg  <- sum(ifelse(rec %in% rel, 1 / log2(seq_along(rec) + 1), 0))
  idcg <- sum(1 / log2(seq_len(min(length(rel), k)) + 1))
  if (idcg == 0) 0 else dcg / idcg
}

evaluate_model <- function(model, test_rel, n = 10, max_users = 2000L) {
  users <- names(test_rel)
  if (length(users) > max_users) users <- sample(users, max_users)
  per_user <- rbindlist(lapply(users, function(u) {
    recs <- recommend_items(model, user_id = u, n = n)$itemid
    rel  <- test_rel[[u]]
    data.table(precision = precision_at_k(recs, rel, n),
               recall    = recall_at_k(recs, rel, n),
               map       = ap_at_k(recs, rel, n),
               ndcg      = ndcg_at_k(recs, rel, n))
  }))
  list(mean = per_user[, .(precision_at_k = mean(precision),
                           recall_at_k    = mean(recall),
                           map_at_k       = mean(map),
                           ndcg_at_k      = mean(ndcg))],
       per_user = per_user, k = n, n_users = nrow(per_user))
}