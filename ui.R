ui <- fluidPage(
  # Application title
  titlePanel("Correlation between Copy Number and Gene Expression"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the br()
  # element to introduce extra vertical spacing
  sidebarPanel(
    tags$h3("Needed for plot:"),
    fileInput('cnvFile', 'Upload band CNV table created by preprocessing-CNA-GSEA.R. This is \"byBandFile\" in config.R'),
    fileInput('gseaFile', 'Upload GSEA table created outside of this program. \"gseaInput\"'),
    fileInput('categoryFile', '(Optional) Upload categorical file created outside of this program.'),
    tags$hr(),
    tags$h3("Needed for table:"),
    fileInput('file1', 'Upload correlation table created by computation-CNA-GSEA.R'),
    uiOutput("signature"),
    uiOutput("band"),
    uiOutput("category")
    
  ),
  
  # Show a tabset that includes a plot, summary, and table view
  # of the generated distribution
  mainPanel(
    tabsetPanel(
      tabPanel("Plot", plotOutput("plot")), 
      tabPanel("Summary", verbatimTextOutput("summary")), 
      tabPanel("Table", dataTableOutput("table"))
    )
  ),
  mainPanel(
    tags$a(href="http://nickgros.com/shiny.html", "nickgros.com")
  )
)
