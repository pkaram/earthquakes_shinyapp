fluidPage(
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

