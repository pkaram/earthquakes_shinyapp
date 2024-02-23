library(gdata)
library(shiny)
library(leaflet)
library(dplyr)
library(readxl)

data_temp<-read_xls("/home/earthquakes-shinyapp/1900_2009_mkk.xls",sheet=1)
data_temp<-data_temp %>% mutate(date_time=paste(YEAR,MONTH,DAY,HOUR,MIN,SEC))
data_temp<-data_temp %>% mutate(date_time=as.POSIXct(date_time,format="%Y %m %d %H %M %S"))
data_temp<-data_temp %>% select(Date=date_time,
                      Latitude=LAT,
                      Longitude=LON,
                      Depth=DEP,
                      Magnitude_Ms=Ms,
                      Magnitude_Mw=Mw
                      )

ui <- fluidPage(
  headerPanel('Earthquake Catalogue for Greece and adjacent areas 1900-2009'),
  sidebarPanel(
    radioButtons('type', 'Select Earthquake Type',
                 c('Surface Wave Magnitude'="Ms",
                   'Moment Magnitude'="Mw"),
                 selected='Ms'),
    selectInput("rel","",choices = as.list(c(">"=">",
                                             ">="='>=',
                                             "<"='<',
                                             "<="='<='
    )),selected = ">"),
    
    radioButtons('mag', ' ',
                 c("7"=7,
                   "6"=6,
                   "5"=5,
                   "4"=4
                 ),
                 selected=7),
    tags$hr(),
    checkboxInput('all', 'All Earthquakes For Type Selected', FALSE),
    tags$hr(),
    dateRangeInput("rangedate","Select Date Range",start = "1900-01-01", end = "2009-12-31",format = "yyyy-mm-dd",separator = '-'),
    tags$hr(),
    #open source of data in new tab
    p(a("Source", href = "http://www.gein.noa.gr/en/seismicity/earthquake-catalogs", target = "_blank"))
  ),
  
  mainPanel(
    leafletOutput('myMap'),
    tags$hr(),
    DT::dataTableOutput("eqlist")
  )
)

server <- function(input, output) {
  #data based on selection of radiobutton and selectinput
  data_filter<-reactive({
    
    #define magnitude based on type selected
    if (as.character(input$type)=='Ms') {
      p1<-data_temp %>% mutate(Magnitude=Magnitude_Ms)
    } else if (as.character(input$type)=='Mw') {
      p1<-data_temp %>% mutate(Magnitude=Magnitude_Mw)
    }
    #selecting the subset of earthquakes to be plotted
    if (input$rel=='>') {
      p<-p1 %>% filter(Magnitude>as.integer(input$mag))
    } else if (input$rel=='>=')   {
      p<-p1 %>% filter(Magnitude>=as.integer(input$mag))
    } else if (input$rel=='<')   {
      p<-p1 %>% filter(Magnitude<as.integer(input$mag))
    } else if (input$rel=='<=')   {
      p<-p1 %>% filter(Magnitude<=as.integer(input$mag))
    } 
    #If user wants to see all earthquakes regardless Magnitude
    if (input$all==TRUE) {p<-p1}
    #return p
    p
  })
  
  #data based on selection && date range
  dseldata<-reactive({
    data_filter<-data_filter()
    if (nrow(data_filter)!=0 ) {
      data_filter$Date<-as.Date(data_filter$Date)
      #start date of range
      start1<-as.character(input$rangedate[1])
      #end date of range
      end1<-as.character(input$rangedate[2])
      start1<-as.Date(start1,"%Y-%m-%d")
      end1<-as.Date(end1,"%Y-%m-%d")
      #Control if start date is before end date
      if (start1<=end1) {
        sp<-min(which(data_filter$Date>=start1))
        ep<-max(which(data_filter$Date<=end1))
      } else {
        sp<-0
        ep<-0
      }
      #if there is no data for selected data sp and ep gine Inf/-Inf result. To control this:
      if (is.infinite(sp) || is.infinite(ep)) {
        sp<-0
        ep<-0
      }
      drdata<-data_filter[sp:ep,]
      #rownames(drdata)<-NULL
      if (is.infinite(sp) || is.infinite(ep)) {
        sol<-data.frame() 
      } else {
        sol<-drdata
      }
    } else {
      sol<-data.frame() 
    }
    
    sol <- sol %>% select(-Magnitude_Ms,-Magnitude_Mw)
  })
  
  #plot for map and earthquakes
  output$myMap = renderLeaflet({
    if (nrow(dseldata())==0) {
      leaflet() %>% addTiles() 
    } else {
      leaflet() %>% addTiles() %>% addCircleMarkers(data = dseldata(), lat = ~Latitude, lng = ~Longitude,radius = ~Magnitude,
                                                    popup=~as.character(paste(Date,paste("Depth:",Depth,sep=""),paste("Magnitude: ",Magnitude,sep=""),sep=" | "))) 
    }
  })
  
  #it shows data for choices (magnitude and date range) made by the user
  output$eqlist<-DT::renderDataTable({
    dseldata()
  })
  
}



shinyApp(ui = ui, server = server)