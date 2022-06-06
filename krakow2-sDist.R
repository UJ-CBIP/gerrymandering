require(Smisc)
require(rlist)
select <- dplyr::select
probDF0 <- aggregate(expectS ~ rok + gmina + koalicja, filter(wyb, rok==9999), function(p) {
  dkbinom(c(0:length(p)), rep(1, length(p)), p)
})
probDF <- list.rbind(
  apply(probDF0, 1, function(row) {
    cc <- length(row[[4]])
    data.frame(t(sapply(1:cc, function(i) c(row[[1]], row[[2]], row[[3]], i-1, row[[4]][i]))))
  }))
colnames(probDF) <- c("rok", "gmina", "lista", "s", "prob")

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerrySDist;")
sqlSaveBulk(hdbc, probDF, "gerry.gerrySDist")
sqlQuery(hdbc, "UPDATE gerry.gerrySDist SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerrySDist AS d INNER JOIN (
    SELECT rok, gmina, lista, s, prob, SUM(prob) OVER (PARTITION BY rok, gmina, lista ORDER BY s) AS cdf FROM gerry.gerrySDist
  ) AS x ON d.rok = x.rok AND d.gmina = x.gmina AND d.lista = x.lista AND d.s = x.s SET d.cdf = x.cdf;")
