summarize <- dplyr::summarize

hdbc <- odbcConnect("cbip", case="nochange")
winpct <- sqlQuery(hdbc, "SELECT LEAST(w.listOkr, 9) AS n, w.elk, w.thold, g.v,
  POWER(g.okr / g.cGmina, 0) AS w FROM gerry.gerryWybory AS w
  INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
  WHERE w.mandat = 1 AND w.rok = 2014")
normdf <- sqlQuery(hdbc, "SELECT w.rok, w.gmina, w.koalicja AS lista, g.shift, w.listOkr AS n, w.elk, w.thold, g.v, g.s FROM gerry.gerryWybory AS w
  INNER JOIN gerry.gerryHypoSV AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
  WHERE w.listOkr > 1 AND w.rok = 9999")

normalizeV <- function (k) {
  qvec <- quantile(winpct$thold, probs = (0:k)/k)
  # qvec[1] <- 0
  qvec <- c(unique(qvec), 1)
  k <- length(qvec)-1
  winpct$interval <- findInterval(winpct$thold, vec=qvec) # rightmost.closed = TRUE, left.open = TRUE
  wcdfList <- lapply(1:k, function(i) with(filter(winpct, interval==i), ewcdf(v, w)))
  normdf$interval <- findInterval(normdf$thold, vec=qvec, all.inside=TRUE)
  normdf$normV <- apply(select(normdf, v, interval), 1, function(x) wcdfList[[x[2]]](x[1]))
  normdfGrp <- normdf %>% group_by(rok, gmina, lista, shift) %>%
    summarize(v = mean(v), n = mean(n), elk = mean(elk), t = mean(thold), i = mean(interval), s = mean(s), normV = mean(normV), c = length(v), .groups="keep")
  normdfGrp
}

saveNormV <- function(df) {
  sqlQuery(hdbc, "DELETE FROM gerry.gerryNormV WHERE rok = 9999")
  sqlQuery(hdbc, "DELETE FROM gerry.gerryHypoNormV WHERE rok = 9999")
  sqlSaveBulk(hdbc, df, "gerry.gerryHypoNormV")
  sqlQuery(hdbc, "UPDATE gerry.gerryHypoNormV SET gmina = LPAD(gmina, 6, '0');")
  sqlQuery(hdbc, "INSERT INTO gerry.gerryNormV
    SELECT rok, gmina, lista, v, n, elk, t, i, s, c, normV FROM gerry.gerryHypoNormV WHERE shift = 0 AND rok = 9999;")
  sqlQuery(hdbc, "UPDATE gerry.gerry AS g
    INNER JOIN gerry.gerryNormV AS nv ON g.rok = nv.rok AND g.gmina = nv.gmina AND g.lista = nv.lista
    SET g.normV = nv.normV WHERE g.rok = 9999;")
  sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
    INNER JOIN gerry.gerryHypoNormV AS nv ON g.rok = nv.rok AND g.gmina = nv.gmina AND g.lista = nv.lista AND g.shift = nv.shift
    SET g.normV = nv.normV WHERE g.rok = 9999;")
}

ndf99 <- normalizeV(220)
saveNormV(ndf99)
