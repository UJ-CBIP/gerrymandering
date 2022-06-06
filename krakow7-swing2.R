hdbc <- odbcConnect("cbip", case="nochange")
swing <- sqlQuery(hdbc, "SELECT s.rok, s.gmina, s.lista1, s.lista2, s.method, s.man, s.swing,
  w.okreg, w.listOkr AS n, w.pct AS v, w.glosOkr AS w FROM gerry.gerryIntersect AS i
  INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
  INNER JOIN gerry.gerrySwing AS s ON s.rok = i.rok AND s.gmina = i.gmina AND s.lista1 = i.lista1 AND s.lista2 = i.lista2
  WHERE i.rok = 9999 AND s.method != 'uniform' AND s.method != 'probit0'")
swing$vv <- NA
swing$vv <- pmap_dbl(select(swing, r = rok, n, method, v, swing),
   function(r, n, method, v, swing) {
     kde <- ddf$kde[ddf$r == 2014 & ddf$n == n][[1]]
     if (method == 'quantile') {
       qkde1d(pmax(pmin(pkde1d(v, kde) + swing, 1), 0), kde)
     } else if (method == 'probit') {
       qkde1d(pnorm(qnorm(pkde1d(v, kde)) + swing), kde)
     } else if (method == 'logit') {
       qkde1d(inv.logit(logit(pkde1d(v, kde)) + swing), kde)
     }
   })
swingSum <- group_by(swing, rok, gmina, lista1, lista2, method, man) %>%
  summarize(v = weighted.mean(vv, w))
hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "DELETE FROM gerry.gerrySwing2 WHERE rok = 9999;")
sqlSaveBulk(hdbc, swingSum, "gerry.gerrySwing2")
sqlQuery(hdbc, "UPDATE gerry.gerrySwing2 SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerrySwing AS s1 INNER JOIN gerry.gerrySwing2 AS s2 ON
  s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.lista1 = s1.lista1 AND s2.lista2 = s1.lista2 AND s2.method = s1.method AND s2.man = s1.man
  SET s1.v = s2.v;")
