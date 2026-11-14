library(ggplot2)

server <- function(input, output, session) {
  recs <- eventReactive(input$go, {
    req(model)
    recommend_items(model, user_id = input$user, n = input$n)
  })
  output$recs    <- renderTable(recs())
  output$recplot <- renderPlot(
    ggplot(recs(), aes(reorder(itemid, score), score)) +
      geom_col(fill = "#2c7fb8") + coord_flip() + labs(x = NULL))
  output$popplot <- renderPlot({
    req(model)
    top <- data.table(itemid = model$item_index,
                      pop = model$popularity)[order(-pop)][1:20]
    ggplot(top, aes(reorder(itemid, pop), pop)) +
      geom_col(fill = "#41ab5d") + coord_flip() + labs(x = NULL)
  })
  output$metrics <- renderPrint({ req(model); print(model$metrics$mean) })
  output$registry <- renderTable({
    req(!is.null(con))
    DBI::dbGetQuery(con, "SELECT * FROM model_registry ORDER BY trained_at DESC LIMIT 20")
  })
}