summarize <- dplyr::summarize

hdbc <- odbcConnect("cbip", case="nochange")
winpct <- sqlQuery(hdbc, "SELECT LEAST(w.listOkr, 9) AS n, w.elk, w.thold, g.v,
  POWER(g.okr / g.cGmina, 0) AS w FROM gerry.gerryWybory AS w
  INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
  WHERE w.mandat = 1 AND w.rok = 2014")
normdf <- sqlQuery(hdbc, "SELECT w.rok, w.gmina, w.koalicja AS lista, g.shift, w.listOkr AS n, w.elk, w.thold, g.v, g.s FROM gerry.gerryWybory AS w
  INNER JOIN gerry.gerryHypoSV AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
  WHERE w.listOkr > 1 AND w.rok = 2014")

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

# ndf18 <- normalizeV(18)
# ndf36 <- normalizeV(36)
# ndf72 <- normalizeV(72)
# ndf144 <- normalizeV(144)

saveNormV <- function(df) {
  sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryHypoNormV")
  sqlSaveBulk(hdbc, df, "gerry.gerryHypoNormV")
  sqlQuery(hdbc, "UPDATE gerry.gerryHypoNormV SET gmina = LPAD(gmina, 6, '0');")
  sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryNormV")
  sqlQuery(hdbc, "INSERT INTO gerry.gerryNormV
    SELECT rok, gmina, lista, v, n, elk, t, i, s, c, normV FROM gerry.gerryHypoNormV WHERE shift = 0;")
  sqlQuery(hdbc, "UPDATE gerry.gerry AS g
    INNER JOIN gerry.gerryNormV AS nv ON g.rok = nv.rok AND g.gmina = nv.gmina AND g.lista = nv.lista
    SET g.normV = nv.normV;")
  sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
    INNER JOIN gerry.gerryHypoNormV AS nv ON g.rok = nv.rok AND g.gmina = nv.gmina AND g.lista = nv.lista AND g.shift = nv.shift
    SET g.normV = nv.normV;")
}

saveNormV0 <- function(df) {
  sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryNormV")
  sqlSaveBulk(hdbc, df, "gerry.gerryNormV")
  sqlQuery(hdbc, "UPDATE gerry.gerryNormV SET gmina = LPAD(gmina, 6, '0');")
  sqlQuery(hdbc, "UPDATE gerry.gerry AS g
    INNER JOIN gerry.gerryNormV AS nv ON g.rok = nv.rok AND g.gmina = nv.gmina AND g.lista = nv.lista
    SET g.normV = nv.normV;")
}

ndf <- normalizeV(220)
saveNormV(ndf)
# saveNormV0(select(as.data.frame(filter(ndf, shift==0)), 1:11, -shift))

ndf2 <- subset(inner_join(ndf, select(gdf14, rok, gmina, lista, okr, cGmina, x=v, avgThold)), shift==0)

ggplot(ndf2, aes(v, normV, col=i)) + geom_point() +
  scale_color_gradient2(high="red", mid="green", low="blue", midpoint = 80) +
  geom_point(data = filter(ndf2, i == 161, okr == cGmina, shift==0), aes(v, normV), col="black")

# ggplot(ndf4, aes(v, normV, col=s)) + geom_point() + scale_color_gradient(low='black', high='white')
# ggplot(filter(gdf14, okr >= cGmina / 2, !near(normV, 0)), aes(pValue, uqNorm)) + geom_point()