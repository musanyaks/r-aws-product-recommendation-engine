# Shared fixture: 2 users, 4 items, known structure.
# Auto-loaded by testthat for tests/testthat/; sourced explicitly by tests/test_api.R.
make_tiny_model <- function() {
  users <- c("u1", "u2"); items <- c("i1", "i2", "i3", "i4")
  P <- matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE)
  Q <- matrix(c(1, 0, 0.9, 0.1, 0, 1, 0.1, 0.9), nrow = 4, byrow = TRUE)
  list(cf = list(P = P, Q = Q),
       content_feats = Matrix::Diagonal(4),
       popularity = c(0.1, 0.2, 0.3, 0.9),
       train_mat = Matrix::sparseMatrix(i = c(1, 2), j = c(1, 3), x = c(1, 1), dims = c(2, 4)),
       user_index = users, item_index = items,
       weights = list(cf = 0.5, cb = 0.3, pop = 0.2))
}