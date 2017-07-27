# cnv-gsea-correlation

A tool for identifying correlations between chromosomal copy number and gene set enrichment scores (or any other continuous feature) across multiple samples.

## Getting Started

This tool consists of a sequence of R scripts that process the following input files:
* A table of copy numbers per-gene for each sample
* A table of gene set enrichment/other feature scores for each sample
* (Optional) A category for each sample to separate correlative analyses

### Prerequisites

* [R](https://cran.r-project.org/)

The following libraries are also required and can be installed in R with install.packages (below)
  * [dplyr](https://cran.r-project.org/web/packages/dplyr/)
  * [tidyr](https://cran.r-project.org/web/packages/tidyr/)
  * [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html) (optional for plotting)
  * [ggpmisc](https://cran.r-project.org/web/packages/ggpmisc/index.html) (optional for plotting)
  * [data.table](https://cran.r-project.org/web/packages/data.table/)
  * parallel (should be installed with R base)

```R
install.packages(c("dplyr", "tidyr", "ggplot2", "ggpmisc", "data.table"))
```

This project also includes a Shiny application that can be used to aid in interpreting the data. To use the Shiny app, the optional packages above must also be installed.


### Installing

Download the package by navigating above or click [here](https://github.com/nickgros/cnv-gsea-correlation/archive/master.zip)

## Running the scripts

Before running the scripts, edit or duplicate the config file (config.R) and specify the file names and parameters for the program. Initially, the config file is set to run on the included example files.

The scripts can be run from the terminal using the Rscript command. Make sure you specify a config file after the program.

```
Rscript preprocessing-CNA-GSEA.R config.R
Rscript computation-CNA-GSEA.R config.R
```
...and so on.

The Shiny application must be run in a graphical desktop environment. This can be done by calling the following in R:

```R
shiny::runApp("~/cna-gsea-correlation-directory/")
```

where the directory is the unzipped directory of this project (i.e. it contains server.R).


### Tips

* Make sure all of your files are formatted the same way as the examples (tab-delimited, samples as columns, sample names match between files)
  * The GSEA file is formatted identically to the output in the [GSVA] (https://bioconductor.org/packages/release/bioc/html/GSVA.html) package on Bioconductor.

### Contact

If you have any issues running the script, contact the author
