# Use rocker/shiny as the base image
FROM rocker/shiny:4

# Install R packages required 
# Change the packages list to suit your needs
RUN R -e "install.packages(c('shiny', 'wdman', 'RSelenium', 'httr'), dependencies=TRUE)"

FROM base as builder

# install all packages for chromedriver: https://gist.github.com/varyonic/dea40abcf3dd891d204ef235c6e8dd79
RUN apt-get update && \
    apt-get install -y xvfb gnupg wget curl unzip --no-install-recommends && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update -y && \
    apt-get install -y google-chrome-stable && \
    CHROMEVER=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") && \
    DRIVERVER=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMEVER") && \
    wget -q --continue -P /chromedriver "http://chromedriver.storage.googleapis.com/$DRIVERVER/chromedriver_linux64.zip" && \
    unzip /chromedriver/chromedriver* -d /chromedriver

# make the chromedriver executable and move it to default selenium path.
RUN chmod +x /chromedriver/chromedriver
RUN mv /chromedriver/chromedriver /usr/bin/chromedriver

# Expose Shiny and Selenium ports
EXPOSE 5000 4567

# Set up the working directory
WORKDIR /home/shinyusr

# Copy the Shiny app files
COPY app.R app.R 

# Start Selenium and run Shiny app
CMD ["/bin/bash", "-c", "java -jar /usr/bin/selenium-server-standalone.jar -port 4567 & R -e 'shiny::runApp(\"app.R\", port = 5000, host = \"0.0.0.0\")'"]
