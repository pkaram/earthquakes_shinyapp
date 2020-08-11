#interactive map, which loads data of earthquakes over the period 1900-2009
#Option for magnitude/Option for date Range
#Under the map is presented the list of earthquakes for options selected

function(input, output) {
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
