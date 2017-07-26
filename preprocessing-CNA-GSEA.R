# Cleaning data for correlative analysis between copy number data and GSEA data
# Use config.R to specify details
# See README for more info
# Contact: Nick Grosenbacher | grosenbacher.1(at)osu.edu
require(data.table)
require(dplyr)
require(tidyr)
require(parallel)

# Set up parallelized processes for speed
#TODO: Make this system-independent and add a config option
num_cores <- detectCores()
cluster <- makeCluster(spec = num_cores, type = "FORK") #TODO: Fork only works on *nix!

# Get command-line arguments
args <- commandArgs(TRUE)
configFile <- args[1]
configFile <- "config.R"
source(configFile)
# Read in all of the user input files and process them so they're the right format
cat("\nReading",cnvInput,"\n")
cnv  <- fread(cnvInput, data.table = F)
rownames(cnv) <- cnv[,1]
cnv <- as.data.frame(t(cnv[,-1]))


# CNA is gene level, must convert this to band level
gene_to_band_table <- fread("data/mart_export_chrom_bands_sorted.txt", data.table = F)
gene_to_band_table$chrBand <- paste(gene_to_band_table$`Chromosome Name`, gsub("(\\.).*", "", gene_to_band_table$Band), sep="")

# For each band, look up the copy number value of associated genes, set the CNV of that band to the mean gene CNV
cat("\nCalculating copy number by band (this may take a minute if you have a lot of samples)\n")
clusterExport(cluster, varlist = c("cnv", "gene_to_band_table"))
cnv_by_band <- parApply(cluster, cnv, 1, function(x){
  temp_band_row <- data.frame()
  data <- as.numeric(x)
  names(data) <- colnames(cnv)
  for(band in unique(gene_to_band_table$chrBand)){
    genes_in_band <- gene_to_band_table$`HGNC symbol`[gene_to_band_table$chrBand == band]
    mean_cnv <- mean(data[genes_in_band], na.rm = T)
    temp_band_row <- rbind(temp_band_row, data.frame(band=band,cnv=mean_cnv))
  }
  return(temp_band_row)
})
stopCluster(cluster)
cnv_by_band <- cnv_by_band %>% bind_rows(.id = "sample")

cat("\nWriting",byBandFile,"\n")
fwrite(x = cnv_by_band, file = byBandFile, quote = F, sep = '\t')
cat("\nDone preprocessing!\n")