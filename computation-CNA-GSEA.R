# Running correlative analysis between copy number data and GSEA data and outputting tables with results
# Use config.R to specify details
# See README for more info
# Contact: Nick Grosenbacher | grosenbacher.1(at)osu.edu
library(dplyr)
library(tidyr)
library(parallel)
library(data.table)

# Get command-line arguments
args <- commandArgs(TRUE)
configFile <- args[1]

source(configFile)
# Read in all of the user input files and process them so they're the right format
cnv_by_band <- fread(byBandFile, data.table = F)
#For some bands, there are not enough genes with known copy number to get a CNV value, so remove the NA bands
cnv_by_band <- cnv_by_band %>% na.omit
gsea <- fread(gseaInput, data.table = F)
if (separateSamples) {
  sample_categories <- fread(separationInput, data.table = F)
  sample_categories[,2] <- factor(sample_categories[,2])
  num_categories <- length(levels(sample_categories[,2]))
}

if (varianceThreshold > 0) {
  cnv_nested_by_patient <- cnv_by_band %>% nest(c("band", "cnv"))
  # Remove samples with low CNV variance - strengthens noise and removes samples of low tumor purity
  # currently removing bottom 50%
  var <- numeric()
  for(sample in 1:nrow(cnv_nested_by_patient[,1])) {
    var[[length(var) + 1]] <- var(cnv_nested_by_patient$data[[sample]]$cnv)
  }
  cnv_nested_by_patient <- cnv_nested_by_patient[var >= quantile(var, varianceThreshold),]
  #filter the original data frame by variance and recreate the frame nested by band as well
  cnv_by_band <- cnv_by_band[which(cnv_by_band$sample %in% cnv_nested_by_patient[[1]]),]
  rm(cnv_nested_by_patient)
}

  
# Filter GSEA samples to match the CNV patients
gsea <- gsea[,c(colnames(gsea)[[1]], unique(cnv_by_band$sample))]

# Set up parallelized processes for speed
#TODO: Make this system-independent and add a config option
num_cores <- detectCores()
cluster <- makeCluster(spec = num_cores, type = "FORK") #TODO: Fork only works on *nix!
clusterExport(cluster, varlist="gsea")
# Read in the function that handles computing and outputting correlation
source("writeCorrelTable.R")
if (separateSamples) {
  for(category in levels(sample_categories[,2])) {
    current_samples <- sample_categories[,1][which(sample_categories[,2] == category)]
    temp_cnv_by_band <- cnv_by_band[which(cnv_by_band$sample %in% current_samples),]
    #Nest CNV data into a list that separates each band (this will make parallel processing easier)
    temp_nested_by_band <- temp_cnv_by_band %>% nest(colnames(temp_cnv_by_band)[which(colnames(temp_cnv_by_band) != "band")])
    clusterExport(cluster, varlist="temp_nested_by_band")
    outfile <- paste(correlOutputPrefix,"-",category,"-correlation.txt",sep="")
    temp_correl_table <- writeCorrelTable()
    if (maxP < 1) {
      temp_correl_table %>% filter(p.value < maxP)
    }
    fwrite(x = temp_correl_table, file=outfile, quote = F, col.names = T, sep = '\t')
  }
} else {
  clusterExport(cluster, varlist="cnv_by_band")
  temp_correl_table <- writeCorrelTable()
  if (maxP < 1) {
    temp_correl_table %>% filter(p.value < maxP)
  }
  fwrite(x = temp_correl_table, file=outfile, quote = F, col.names = T, sep = '\t')
}
stopCluster(cl)




names(test.table) <- replicate(paste(letters[runif(n = 20, min = 1, max=26)], collapse = ""), n = length(test.table))
