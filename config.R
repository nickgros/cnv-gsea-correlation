####Config file for CNA-GSEA correlation analysis####

###Global variables - These must be defined for all scripts
##  Copy number file name:
#   This should be an m x n matrix where m (rows) is samples and n (columns) is genes (Hugo Symbols),
#   and each value is the copy number of that gene relative to 0 (where 0 is diploid)
cnvInput <- "example/cnv.txt"

##  Gene signature file name:
#   This should be an m x n matrix where m (rows) is gene signatures and n (columns) is samples.
#   It should be possible to use any continuous feature here (e.g. normalized gene expression).
gseaInput <- "example/gsea.txt"

##  Separation variable:
#   If you want to separate your analysis based on a discrete feature, insert an m x 2 matrix where
#   column 1 is sample names and column 2 is the discrete feature per sample
separateSamples <- FALSE
separationInput <- "example/estrogen_status_IHC.txt"

##  Band-average file name:
#   A file that will be output by the preprocessing script and will be input for later scripts
byBandFile <- "example/cnv_bands.txt"

#TODO: Implement band sensitivity. Selection between chromosome/arm/band/sub-band level of specificity


###Preprocessing variables - These are only used in the preprocessing script.
## Output Principle Components Analysis plot:
#  This will create a plot of samples based on their first two principal components
#  if separateSamples is TRUE, then the plot will be colored by that feature
outputPCA <- TRUE
pcaOutput <- "example/pca-by-estrogen.png"

# TODO:Implement heatmap generation in the cleaning/preprocessing step

## Gene-chromosome lookup table
#  Don't modify this unless you know what you're doing
#  A table retrieved from biomart that has the chromosomal location of each gene
geneLookupFile <- "data/mart_export_chrom_bands_sorted.txt"


###


