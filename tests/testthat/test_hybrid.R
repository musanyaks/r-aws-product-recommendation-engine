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

test_that("cold-start user falls back to popularity", {
  m <- make_tiny_model()
  rec <- recommend_items(m, user_id = "ghost", n = 4)
  expect_equal(rec$itemid[1], "i4")
})

test_that("already-seen items are never recommended", {
  m <- make_tiny_model()
  rec <- recommend_items(m, user_id = "u1", n = 10)
  expect_false("i1" %in% rec$itemid)
})

test_that("similar_items excludes the item itself", {
  m <- make_tiny_model()
  sim <- similar_items(m, "i2", n = 3)
  expect_false("i2" %in% sim$itemid)
})