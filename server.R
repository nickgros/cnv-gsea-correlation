# server.R
library(data.table)
library(ggplot2)
library(ggpmisc)
library(dplyr)
options(shiny.maxRequestSize=500*1024^2) 
#correl.table <- NULL
server <- function(input, output, session) {
  
  tables <- reactiveValues()
  
  
  output$band <- renderUI({
    req(input$cnvFile)
    tables$cnv.table <- fread(input$cnvFile$datapath, data.table = F)
    selectInput(inputId = "band", label = "Select a band(s) to plot.",
                choices = unique(tables$cnv.table$band),  multiple = T)
  })
  
  
  output$signature <- renderUI({
    req(input$gseaFile)
    tables$gsea.table <- fread(input$gseaFile$datapath, data.table = F)
    selectInput(inputId = "signature", label = "Select a signature to plot.",
                choices = unique(tables$gsea.table[,1]),  multiple = F)
  })

  output$category <- renderUI({
    req(input$categoryFile)
    
    tables$category.table <- fread(input$categoryFile$datapath, data.table = FALSE)
    checkboxGroupInput(inputId = "category",
                       label = colnames(tables$category.table)[2],
                       choices = unique(tables$category.table[,2]))
    
  })
  
  # Table that lists all correlations with bands and relevant statistics.
  # Requires user to upload the table generated in the computation script.
  output$table <- renderDataTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    req(inFile)
    correl.table <<- fread(inFile$datapath, data.table = F)
    return(correl.table)
  })
  
  

  


  # Generate a plot of the data. Also uses the inputs to build the 
  # plot label. Note that the dependencies on both the inputs and
  # the 'data' reactive expression are both tracked, and all expressions 
  # are called in the sequence implied by the dependency graph
  output$plot <- renderPlot({
    cnvFile <- input$file2
    gseaFile <- input$file3
    
    req(tables$cnv.table, tables$gsea.table, input$band)
    
    
    plot.df <- tables$cnv.table %>% filter(band %in% input$band)
    plot.df$band <- factor(plot.df$band)
    plot.df$phenotype <- as.numeric(tables$gsea.table[which(tables$gsea.table[,1] == input$signature), plot.df$sample])
    
    if(!is.null(tables$category.table) && !is.null(input$category)) {
      plot.df$category <- tables$category.table[,2][match(x = plot.df$sample, table = tables$category.table$sample)]
      plot.df <- plot.df[which(plot.df$category %in% input$category),]
    }
    
    plot <- ggplot(plot.df,
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
      ylab(input$signature) + theme(legend.position = "bottom")
    if (is.null(input$category)) {
      plot <- plot + facet_grid( ~ band)
    } else {
      plot <- plot + facet_grid(category ~ band)
    }
    plot
  })
  
  # Generate a summary of the data
  # Could put linear model info here
  # output$summary <- renderPrint({
  #   summary(data())
  # })
  
}
