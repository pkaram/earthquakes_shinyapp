FROM rocker/shiny
RUN mkdir /home/earthquakes-shinyapp
RUN R -e "install.packages(c('dplyr', 'leaflet', 'shiny', 'gdata','readxl','DT'))"
COPY app.R /home/earthquakes-shinyapp/app.R
COPY 1900_2009_mkk.xls /home/earthquakes-shinyapp/1900_2009_mkk.xls
WORKDIR /home/earthquakes-shinyapp
CMD ["R", "-e", "shiny::runApp(host='0.0.0.0', port=8180)"]
EXPOSE 8180