# Resolve endpoints.R relative to THIS file, not the working directory.
this_file <- tryCatch(
  normalizePath(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])),
  error = function(e) NULL
)
api_dir <- if (!is.null(this_file) && !is.na(this_file)) dirname(this_file) else "api"
source(file.path(api_dir, "endpoints.R"))
#* @apiTitle Product Recommendation API
#* @apiDescription Hybrid CF + content-based + popularity recommendations from R.

#* API-key auth on everything except health/docs
#* @filter auth
function(req, res) {
  public <- c("/health", "/__docs__/", "/openapi.json")
  is_public <- any(startsWith(req$PATH_INFO, public))

  if (!is_public && !identical(req$HTTP_X_API_KEY, config$api_key)) {
    res$status <- 401L
    return(list(error = "missing or invalid API key"))
  }

  plumber::forward()
}
#* Health check
#* @get /health
function() handle_health()

#* Personalized recommendations
#* @param recent Optional comma-separated recently-viewed item ids (cold-start aid)
#* @get /recommendations/<user_id>
function(user_id, n = 10, recent = "") handle_recommendations(user_id, n, recent)

#* Similar products (content-based)
#* @get /similar/<item_id>
function(item_id, n = 10) handle_similar(item_id, n)

#* Popular products
#* @get /popular
function(n = 10) handle_popular(n)

#* Record a customer interaction for the next retraining run
#* @post /feedback
function(req, res) handle_feedback(req, res)