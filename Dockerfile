# Use rocker/shiny as the base image
FROM rocker/shiny:4

# Install R packages required 
# Change the packages list to suit your needs
RUN R -e "install.packages(c('shiny', 'wdman', 'RSelenium', 'httr'), dependencies=TRUE)"

# Install net-tools package for netstat
RUN apt-get update && \
    apt-get install -y net-tools

# Install Selenium and Chrome dependencies
RUN apt-get install -y libappindicator1 fonts-liberation libasound2 libgconf-2-4 libnspr4 libxss1 libnss3 libexif-dev libxcb1 libxtst6 libx11-xcb1 curl gpg

# Download and install Chrome
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub -o linux_signing_key.pub \
    && cat linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/google-archive-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list > /dev/null \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# Install Selenium Server
RUN wget -q https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar -O /usr/bin/selenium-server-standalone.jar

# Expose Shiny and Selenium ports
EXPOSE 5000 4567

# Set up the working directory
WORKDIR /home/shinyusr

# Copy the Shiny app files
COPY app.R app.R 

# Start Selenium and run Shiny app
CMD ["/bin/bash", "-c", "java -jar /usr/bin/selenium-server-standalone.jar -port 4567 & R -e 'shiny::runApp(\"app.R\", port = 5000, host = \"0.0.0.0\")'"]