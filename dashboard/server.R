server <- function(input, output, session) {
  
  # ---------- Overview Tab ----------
  output$vb_users <- renderValueBox({
    valueBox(
      value = scales::comma(catalog$n_users),
      subtitle = "Users",
      icon = icon("users"),
      color = "primary",
      width = NULL
    )
  })
  
  output$vb_items <- renderValueBox({
    valueBox(
      value = scales::comma(catalog$n_items),
      subtitle = "Items",
      icon = icon("box"),
      color = "success",
      width = NULL
    )
  })
  
  output$vb_inter <- renderValueBox({
    valueBox(
      value = scales::comma(catalog$n_inter),
      subtitle = "Training Interactions",
      icon = icon("link"),
      color = "info",
      width = NULL
    )
  })
  
  output$vb_density <- renderValueBox({
    valueBox(
      value = scales::percent(catalog$density, accuracy = 0.001),
      subtitle = "Matrix Density",
      icon = icon("border-all"),
      color = "warning",
      width = NULL
    )
  })
  
  output$ov_pop <- renderPlotly({
    top <- data.table(itemid = model$item_index, pop = model$popularity)[order(-pop)][1:20]
    p <- ggplot(top, aes(reorder(itemid, pop), pop)) +
      geom_col(fill = "#007bff") +
      coord_flip() +
      labs(x = NULL, y = "Popularity Score") +
      theme_minimal() +
      theme(axis.text.y = element_text(size = 8))
    ggplotly(p)
  })
  
  output$ov_feat <- renderPlotly({
    cov <- data.table(
      status = c("Has Content Features", "No Features"),
      n = c(catalog$n_feat, catalog$n_items - catalog$n_feat)
    )
    plot_ly(cov, labels = ~status, values = ~n, type = "pie",
            marker = list(colors = c("#28a745", "#dc3545")),
            textposition = 'inside',
            textinfo = 'label+percent') %>%
      layout(title = paste0(scales::percent(catalog$n_feat / catalog$n_items, 0.1),
                           " of items usable for content-based filtering"))
  })
  
  output$ov_model <- renderPrint({
    cat("model_id    :", model$model_id, "\n")
    cat("created_at  :", as.character(model$created_at), "\n")
    cat("weights     :", paste(sprintf("%s=%.2f", names(model$weights),
                                     unlist(model$weights)), collapse = "  "), "\n")
    cat("users       :", scales::comma(catalog$n_users), "\n")
    cat("items       :", scales::comma(catalog$n_items), "\n")
    cat("interactions:", scales::comma(catalog$n_inter), "\n")
    cat("density     :", scales::percent(catalog$density, 0.001), "\n")
    cat("feat coverage:", scales::percent(catalog$n_feat / catalog$n_items, 0.1), "\n")
  })
  
  # ---------- Recommendations Tab ----------
  recs <- eventReactive(input$rec_go, {
    req(nzchar(input$rec_user))
    recent <- if (nzchar(input$rec_recent))
      trimws(strsplit(input$rec_recent, ",")[[1]]) else NULL
    recommend_items(model, user_id = input$rec_user, recent_items = recent, n = input$rec_n)
  })
  
  output$rec_coldstart <- renderPrint({
    cs <- !input$rec_user %in% model$user_index
    cat("cold_start:", cs, "\n")
    if (cs) cat("→ Falling back to content + popularity")
  })
  
  output$rec_table <- renderDT({
    req(recs())
    datatable(recs(), options = list(pageLength = 10, dom = "tip"),
              rownames = FALSE) %>%
      formatRound(c("score", "cf", "cb", "popularity"), 4)
  })
  
  output$rec_decomp <- renderPlotly({
    req(recs())
    d <- recs()[1:min(10, .N)]
    long <- melt(d, id.vars = c("itemid", "rank"),
                 measure.vars = c("cf", "cb", "popularity"),
                 variable.name = "component", value.name = "value")
    p <- ggplot(long, aes(reorder(itemid, -rank), value, fill = component)) +
      geom_col(position = "dodge") +
      coord_flip() +
      labs(x = NULL, y = "Component Score", fill = NULL) +
      theme_minimal() +
      scale_fill_brewer(palette = "Set2")
    ggplotly(p)
  })
  
  # ---------- Catalog Tab ----------
  sims <- eventReactive(input$cat_go, {
    req(nzchar(input$cat_item))
    similar_items(model, input$cat_item, n = input$cat_n)
  })
  
  output$cat_table <- renderDT({
    req(sims())
    datatable(sims(), options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
  })
  
  output$cat_pophist <- renderPlotly({
    p <- ggplot(data.frame(pop = model$popularity), aes(pop)) +
      geom_histogram(bins = 60, fill = "#007bff", alpha = 0.8) +
      labs(x = "Popularity Score", y = "Number of Items") +
      theme_minimal()
    ggplotly(p)
  })
  
  # ---------- Model Quality Tab ----------
  output$q_metrics <- renderDT({
    req(model$metrics)
    dt <- as.data.table(model$metrics$mean)
    long <- melt(dt, measure.vars = names(dt),
                 variable.name = "Metric", value.name = "Value")
    datatable(long, options = list(dom = "t"), rownames = FALSE) %>%
      formatRound("Value", 4)
  })
  
  output$q_vs_baseline <- renderPlotly({
    req(model$metrics, model$metrics$baseline_popularity)
    hybrid <- as.numeric(model$metrics$mean)
    base   <- as.numeric(model$metrics$baseline_popularity)
    mets   <- names(model$metrics$mean)
    d <- data.frame(
      metric = rep(mets, 2),
      value = c(hybrid, base),
      model = rep(c("Hybrid", "Popularity Baseline"), each = length(mets))
    )
    p <- ggplot(d, aes(metric, value, fill = model)) +
      geom_col(position = "dodge") +
      labs(y = "Value", x = NULL, fill = NULL) +
      theme_minimal() +
      scale_fill_manual(values = c("Hybrid" = "#28a745", "Popularity Baseline" = "#6c757d"))
    ggplotly(p)
  })
  
  output$q_dist <- renderPlotly({
    req(model$metrics$per_user)
    col <- input$q_metric
    d <- model$metrics$per_user[[col]]
    p <- ggplot(data.frame(x = d), aes(x)) +
      geom_histogram(bins = 40, fill = "#17a2b8", alpha = 0.8) +
      labs(x = paste0(toupper(col), "@", model$metrics$k), y = "Users") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$q_registry <- renderDT({
    req(!is.null(con))
    d <- DBI::dbGetQuery(con,
      "SELECT model_id, algorithm, metrics, trained_at
       FROM model_registry ORDER BY trained_at DESC LIMIT 50")
    datatable(as.data.table(d), options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE)
  })
  
  # ---------- Live Events Tab ----------
  ev_data <- eventReactive(input$ev_refresh, {
    req(!is.null(con))
    as.data.table(DBI::dbGetQuery(con,
      "SELECT customer_id, product_id, event_type, occurred_at
       FROM interactions ORDER BY occurred_at DESC LIMIT 500"))
  }, ignoreNULL = FALSE)
  
  output$ev_table <- renderDT({
    req(ev_data())
    datatable(ev_data(), options = list(pageLength = 15, dom = "tip"), rownames = FALSE)
  })
  
  output$ev_bytype <- renderPlotly({
    req(ev_data())
    d <- ev_data()[, .N, by = event_type]
    p <- ggplot(d, aes(reorder(event_type, N), N)) +
      geom_col(fill = "#6f42c1") +
      coord_flip() +
      labs(x = NULL, y = "Events") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$ev_overtime <- renderPlotly({
    req(ev_data())
    d <- ev_data()[, .N, by = .(minute = as.POSIXct(cut(occurred_at, "hour")))]
    p <- ggplot(d, aes(minute, N)) +
      geom_line(color = "#6f42c1", size = 1) +
      geom_point() +
      labs(x = NULL, y = "Events") +
      theme_minimal()
    ggplotly(p)
  })
}