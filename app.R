library(shiny)
library(RSelenium)
library(httr)
library(wdman)

httr::set_config(httr::config(http_version = 2))
options(shiny.host = "0.0.0.0")
options(shiny.port = 5000)

ui <- fluidPage(
  actionButton("btn", "Click Me!"),
  textOutput("txt"),
)

server <- function(input, output, session) {
  observeEvent(input$btn, {
    # connect to RSelenium
    client_server <- rsDriver(
      browser = "chrome",
      chromever = "114.0.5735.90",
      verbose = FALSE,
      port = free_port()
    )
    
    # connect remote driver to client
    remDr <- client_server$client
    
    # navigate and perform actions
    remDr$navigate("http://www.google.com")
    remDr$maxWindowSize()
    searchText <- "lakeshore hotel in gulshan"
    remDr$findElement("css selector", "textarea[type='search']")$sendKeysToElement(list(searchText, key = 'enter'))
    text <- as.character(remDr$findElement("css selector", "div.zloOqf span.YhemCb")$getElementText())
    output$txt <- renderText(text)
    
    # clean up
    remDr$quit()
  })
}

shinyApp(ui, server)
