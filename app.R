library(shiny)
library(wdman)
library(RSelenium)
library(httr)    
httr::set_config(httr::config(http_version = 2))
options(shiny.host = "0.0.0.0")
options(shiny.port = 5000)

cDrv <- chrome()
eCaps <- list(chromeOptions = list(
  args = c('--headless', '--disable-gpu', '--window-size=1280,800')
))
remDr<- remoteDriver(browserName = "chrome", port = 4567L,
                     extraCapabilities = eCaps)
remDr$open()

# #connect chrome driver
# rDrv <- rsDriver(browser = "chrome", port = 4567L, chromever = "latest")
# 
# # connect remote driver to client
# remDr <- rDrv$client

# remDr$maxWindowSize()
# remDr$navigate("https://google.com")
# Sys.sleep(2)

ui <- fluidPage(
  actionButton("btn", "Click Me!"),
  textOutput("txt"),
)

server <- function(input, output, session) {
  observeEvent(input$btn, {
    remDr$navigate("http://www.google.com")
    remDr$maxWindowSize()
    searchText <- "lakeshore hotel in gulshan"
    remDr$findElement("css selector", "textarea[type='search']")$sendKeysToElement(list(searchText, key = 'enter'))
    text <- as.character(remDr$findElement("css selector", "div.zloOqf span.YhemCb")$getElementText())
    remDr$screenshot(display = TRUE)
    output$txt <- renderText(text)
    # clean up
    remDr$close()
    cDrv$stop()
  })
}

shinyApp(ui, server)