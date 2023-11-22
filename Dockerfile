# Use rocker/shiny as the base image
FROM rocker/shiny:4

# Install R packages required 
# Change the packages list to suit your needs
RUN R -e "install.packages(c('shiny', 'wdman', 'RSelenium', 'httr'), dependencies=TRUE)"

# Install Selenium and Chrome dependencies
RUN apt-get update && \
    apt-get install -y libappindicator1 fonts-liberation libasound2 libgconf-2-4 libnspr4 libxss1 libnss3 libexif-dev libxcb1 libxtst6 libx11-xcb1

# Download and install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable

# Install Selenium Server
RUN wget -q https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar -O /usr/bin/selenium-server-standalone.jar

# Set up the working directory
WORKDIR /home/shinyusr

# Copy the Shiny app files
COPY app.R app.R 

# Start Selenium and run Shiny app
CMD ["/bin/bash", "-c", "java -jar /usr/bin/selenium-server-standalone.jar & Rscript app.R"]
