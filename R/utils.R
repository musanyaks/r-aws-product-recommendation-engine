`%||%` <- function(a, b) if (is.null(a)) b else a

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (!is.finite(rng[1]) || diff(rng) == 0) return(rep(0.5, length(x)))
  (x - rng[1]) / diff(rng)
}