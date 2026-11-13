clean_events <- function(events, max_user_events_q = 0.999) {
  events <- unique(events, by = c("visitorid", "itemid", "event", "transactionid"))
  events <- events[event %in% c("view", "addtocart", "transaction")]
  # Drop the top 0.1% most active visitors: almost always bots/scrapers
  counts <- events[, .N, by = visitorid]
  bots   <- counts[N > quantile(N, max_user_events_q), visitorid]
  events[!(visitorid %in% bots)]
}