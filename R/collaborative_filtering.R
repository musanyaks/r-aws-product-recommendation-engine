# Matrix factorization via recosystem (LIBMF).
# Note: the Reco object holds a C++ pointer that does NOT survive saveRDS().
# We persist the factor matrices P (users x dim) and Q (items x dim) instead;
# serving then only needs a matrix-vector product P[u,] %*% t(Q) — very fast.
train_cf <- function(mat_info, dim, niter, lrate, costp_l2, costq_l2) {
  dm <- recosystem::data_memory(user_index = mat_info$ui,
                                item_index = mat_info$ii,
                                rating     = mat_info$x, index1 = TRUE)
  r <- recosystem::Reco()
  set.seed(42)
  r$train(dm, opts = list(dim = dim, costp_l2 = costp_l2, costq_l2 = costq_l2,
                          lrate = lrate, niter = niter,
                          nthread = parallel::detectCores(), verbose = FALSE))
  # For hyperparameter tuning, swap the above for r$tune(dm, opts$tune(...)).
  out <- r$output(recosystem::out_memory(), recosystem::out_memory())
  list(P = out$P, Q = out$Q, mean_rating = mean(mat_info$x))
}