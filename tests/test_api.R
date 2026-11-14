# Handler-level API tests — no server required. Run from repo root via run_tests.R.
suppressPackageStartupMessages({ library(data.table); library(Matrix) })

for (f in c("utils", "config", "hybrid_model", "content_based", "db",
            "recommendation_service"))
  source(file.path("R", paste0(f, ".R")))
source("tests/testthat/helper_tiny_model.R")
source("api/endpoints.R")

service$model      <- make_tiny_model()
service$model_id   <- "test-model"
service$started_at <- Sys.time()

test_that("health reports status and model id", {
  h <- handle_health()
  expect_equal(h$status, "ok")
  expect_equal(h$model_id, "test-model")
})

test_that("recommendations flag cold start and rank unseen items first", {
  res <- handle_recommendations("u1", n = 4)
  expect_false(res$cold_start)
  expect_true(handle_recommendations("ghost", 4)$cold_start)
  expect_equal(res$recommendations$itemid[4], "i1")   # owned item pushed to last
})

test_that("n is clamped and coerced safely", {
  expect_equal(nrow(handle_recommendations("u1", n = 999)$recommendations), 4L)
  expect_equal(nrow(handle_recommendations("u1", n = "abc")$recommendations), 4L)
})

test_that("similar handler excludes the query item", {
  sim <- handle_similar("i2", n = 3)$similar
  expect_false("i2" %in% sim$itemid)
})

test_that("popular returns highest-popularity item first", {
  expect_equal(handle_popular(4)$popular$itemid[1], "i4")
})

test_that("feedback rejects malformed bodies with 400", {
  req <- new.env(); req$postBody <- '{"user_id":"u1"}'
  res <- new.env()
  out <- handle_feedback(req, res)
  expect_equal(res$status, 400L)
  expect_match(out$error, "required")
})

test_that("feedback returns 503 when DB is not configured", {
  req <- new.env(); req$postBody <- '{"user_id":"u1","item_id":"i2","event":"view"}'
  res <- new.env()
  handle_feedback(req, res)
  expect_equal(res$status, 503L)   # config$db$host is "" by default
})