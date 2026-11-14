test_that("precision and recall @ k are correct", {
  rec <- c("a", "b", "c", "d"); rel <- c("a", "c")
  expect_equal(precision_at_k(rec, rel, 4), 0.5)
  expect_equal(recall_at_k(rec, rel, 4), 1.0)
  expect_equal(precision_at_k(rec, rel, 2), 0.5)
})

test_that("AP@k known answer", {
  # hits at positions 1 and 3: (1/1 + 2/3) / 2
  expect_equal(ap_at_k(c("a", "b", "c", "d"), c("a", "c"), 4), (1 + 2/3) / 2)
})

test_that("NDCG@k known answer", {
  expect_equal(ndcg_at_k(c("a", "b", "c"), c("b"), 3), 1 / log2(3))
})

test_that("rescale01 handles constant vectors", {
  expect_equal(rescale01(c(5, 5, 5)), c(0.5, 0.5, 0.5))
})