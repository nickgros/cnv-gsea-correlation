writeCorrelTable <- function(){
  # Generate the data
  test.table <- parApply(cluster, temp_nested_by_band, 1, function(x) {
    p.value <- list()
    slope <- list()
    r.squared <- list()
    for(signature in 1:nrow(gsea)) {
      model <- summary(lm(as.numeric(gsea[signature,x$data$sample]) ~ x$data$cnv))
      slope[length(slope) + 1] <- model$coefficients[2,1]
      p.value[length(p.value) + 1] <- model$coefficients[2,4]
      r.squared[length(r.squared) + 1] <- model$r.squared
    }
    names(slope) <- rownames(gsea)[1:nrow(gsea)]
    names(p.value) <-  rownames(gsea)[1:nrow(gsea)]
    names(r.squared) <-  rownames(gsea)[1:nrow(gsea)]
    table <- cbind(p.value, slope)
    table <- cbind(table, r.squared)
    return(table)
  })
  test.table <- lapply(test.table, function(x){
    return(as_tibble(x))
  })
  names(test.table) <- temp_nested_by_band$band
  test.table.df <- test.table %>% bind_rows(.id = "band")
  test.table.df <- test.table.df %>% bind_cols(signature = rep(gsea$GeneSet, times = nrow(temp_nested_by_band)))
  test.table.df$p.value <- as.numeric(test.table.df$p.value)
  test.table.df$slope <- as.numeric(test.table.df$slope)
  test.table.df$r.squared <- as.numeric(test.table.df$r.squared)
  return(test.table.df)
}
