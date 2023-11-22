library(shiny)
library(wdman)
library(RSelenium)
options(shiny.host = "0.0.0.0")
options(shiny.port = 5000)

ui <- fluidPage(
  actionButton("btn", "Click Me!"),
  textOutput("txt"),
)

server <- function(input, output, session) {
  observeEvent(input$btn, {
    cDrv <- chrome()
    eCaps <- list(chromeOptions = list(
      args = c('--headless', '--disable-gpu', '--window-size=1280,800')
    ))
    remDr<- remoteDriver(browserName = "chrome", port = 4567L, 
                         extraCapabilities = eCaps)
    remDr$open()
    remDr$navigate("http://www.google.com")
    remDr$maxWindowSize()
    searchText <- "3 star hotel in gulshan in english"
    Sys.sleep(3)
    
    remDr$findElement("css selector", "textarea[type='search']")$sendKeysToElement(list(searchText, key = 'enter'))
    remDr$screenshot(display = TRUE)
    # clean up
    remDr$close()
    cDrv$stop()
    output$txt <- renderText("Clicked!")
  })
}

shinyApp(ui, server)