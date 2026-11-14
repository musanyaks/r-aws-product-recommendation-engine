#* @apiTitle Product Recommendation API
#* @apiDescription Hybrid CF + content-based + popularity recommendations from R.
#* Handler logic lives in api/endpoints.R (loaded by run_api.R).

#* API-key auth on everything except health/docs
#* @filter auth
function(req, res) {
  public <- c("/health", "/__docs__/", "/openapi.json")
  if (any(startsWith(req$PATH_INFO, public))) return(forward())
  if (!identical(req$HTTP_X_API_KEY, config$api_key)) {
    res$status <- 401L
    return(list(error = "missing or invalid API key"))
  }
  forward()
}

#* Health check
#* @get /health
function() handle_health()

#* Personalized recommendations
#* @param recent Optional comma-separated recently-viewed item ids (cold-start aid)
#* @get /recommendations/<user_id>
function(user_id, n = 10, recent = NULL) handle_recommendations(user_id, n, recent)

#* Similar products (content-based)
#* @get /similar/<item_id>
function(item_id, n = 10) handle_similar(item_id, n)

#* Popular products
#* @get /popular
function(n = 10) handle_popular(n)

#* Record a customer interaction for the next retraining run
#* @post /feedback
function(req, res) handle_feedback(req, res)