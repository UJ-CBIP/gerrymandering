hdbc <- odbcConnect("cbip", case="nochange")
# gdf <- sqlQuery(hdbc, "SELECT * FROM gerry.gerry WHERE rok = 2014")
# wyb <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryWybory WHERE rok = 2014")
# alpha <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryAlpha WHERE rok = 2014")

qdf <- sqlQuery(hdbc, "SELECT rok, gmina, lista, v, SUM(IF(n = 2, c, 0)) AS c2, SUM(IF(n = 3, c, 0)) AS c3, SUM(IF(n = 4, c, 0)) AS c4,
    SUM(IF(n = 5, c, 0)) AS c5, SUM(IF(n = 6, c, 0)) AS c6, SUM(IF(n = 7, c, 0)) AS c7, SUM(IF(n = 8, c, 0)) AS c8,
    SUM(IF(n = 9, c, 0)) AS c9, SUM(IF(n = 10, c, 0)) AS c10, SUM(IF(n = 11, c, 0)) AS c11, SUM(IF(n = 12, c, 0)) AS c12
FROM (
    SELECT g.rok, g.gmina, g.lista, g.v, gw.listOkr AS n, COUNT(*) AS c
    FROM gerry.gerryWybory AS gw INNER JOIN gerry.gerry AS g ON g.rok = gw.rok AND g.gmina = gw.gmina AND g.lista = gw.koalicja
    WHERE gw.listOkr > 1 GROUP BY g.rok, g.gmina, g.lista, gw.listOkr
) AS x GROUP BY rok, gmina, lista;")

qdf$q <- 0
# qdf <- inner_join(qdf, select(alpha, rok, a = alpha, b = beta))
qOpt <- apply(qdf, 1, function(x) {
  counts <- c(0, x[5:15])
  a <- filter(alpha, rok == x[1])$beta0
  b <- filter(alpha, rok == x[1])$beta1
  print(sprintf("%d %d %d", x[1], x[2], x[3]))
  optim(
    c(q = x[4]), function(q)
      if ((q > 0) && (q < 1)) {
        abs(sum(Vectorize(qbeta)(q, a, b) * counts) / sum(counts) - x[4])
      } else {2^31},
    lower=0, upper=1, method="L-BFGS-B"
    )
})
qdf$q <- unlist(lapply(qOpt, function(x) x$par))

sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryQ")
sqlSaveBulk(hdbc, qdf, "gerry.gerryQ")
sqlQuery(hdbc, "UPDATE gerry.gerryQ SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerry AS g
  INNER JOIN gerry.gerryQ AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.lista = q.lista
  SET g.q = q.q;")
