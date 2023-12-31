FROM rocker/shiny:4
# install R packages required 
# Change the packages list to suit your needs
RUN R -e "install.packages(c('shiny', 'RSelenium', 'wdman', 'netstat', 'httr'), dependencies=TRUE)"

WORKDIR /home/shinyusr
COPY app.R app.R 
CMD Rscript app.R