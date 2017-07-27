# server.R
library(data.table)
library(ggplot2)
library(ggpmisc)
library(dplyr)
options(shiny.maxRequestSize=500*1024^2) 
#correl.table <- NULL
server <- function(input, output, session) {
  
  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, it will be a data frame with 'name',
  # 'size', 'type', and 'datapath' columns. The 'datapath'
  # column will contain the local filenames where the data can
  # be found.
  output$table <- renderDataTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    correl.table <<- fread(inFile$datapath, data.table = F)
    updateSelectInput(session,inputId = "signature",
                      choices = unique(correl.table$signature))
    return(correl.table)
  })
  
  
  
  output$band = renderUI({
    selectInput('band', 'Select one or more bands to plot:', 
                multiple = T,
                choices = correl.table$band[which(correl.table$signature==input$signature)])
  })
  

  # Reactive expression to generate the requested distribution. This is 
  # called whenever the inputs change. The renderers defined 
  # below then all use the value computed from this expression
  data <- reactive({  
    dist <- switch(input$dist,
                   norm = rnorm,
                   unif = runif,
                   lnorm = rlnorm,
                   exp = rexp,
                   rnorm)
    
    dist(input$n)
  })
  
  # Generate a plot of the data. Also uses the inputs to build the 
  # plot label. Note that the dependencies on both the inputs and
  # the 'data' reactive expression are both tracked, and all expressions 
  # are called in the sequence implied by the dependency graph
  output$plot <- renderPlot({
    cnvFile <- input$file2
    gseaFile <- input$file3
    #sepFile <- input$file4
    if (is.null(cnvFile) || is.null(gseaFile))
      return(NULL)
    
    cnv.table <<- fread(cnvFile$datapath, data.table = F)
    gsea.table <<- fread(gseaFile$datapath, data.table = F)

    if (is.null(input$band))
      return(NULL)
    
    plot.df <- cnv.table %>% filter(band %in% input$band)
    plot.df$band <- factor(plot.df$band)
    plot.df$phenotype <- as.numeric(gsea.table[which(gsea.table[,1] == input$signature), plot.df$sample])
    ggplot(plot.df,
                   aes(x = cnv,
                       y = phenotype
                   )) +
      geom_point(alpha = 1) +
      stat_smooth(method = "lm") +
      stat_fit_glance(method = 'lm',
                      geom = 'text',
                      aes(label = paste("p = ",
                                        signif(..p.value.., digits = 4),
                                        " | r^2 = ",
                                        signif(..r.squared.., digits = 4),
                                        sep = "")),
                      label.x.npc = 'right',
                      label.y.npc = 'bottom',
                      size = 4) +
      ylab(input$signature) + theme(legend.position = "bottom") + facet_grid( ~ band)
  })
  
  # Generate a summary of the data
  # Could put linear model info here
  # output$summary <- renderPrint({
  #   summary(data())
  # })
  
}
