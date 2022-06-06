require(purrr)
require(gtools)
require(scam)
require(kde1d)

hdbc <- odbcConnect("cbip", case="nochange")
ddf <- select(wyb, r = rok, n = listOkr) %>% filter(n > 1) %>% unique() %>% arrange(r, n)
ddf$kde <- pmap(select(ddf, r, n), function(r, n) kde1d(filter(wyb, rok == r, listOkr == n, pct > 0)$pct, xmin=0, xmax=1))

wyb$reqSwing <- with(wyb, (maxComp / (glosOkr - glosow)) / (1 + (maxComp / (glosOkr - glosow))) - pct)
wyb0 <- filter(wyb, listOkr > 1) %>% select(rok, gmina, okreg, lista, listOkr, pct, reqSwing)
wyb0$ecdfV <- pmap_dbl(transmute(wyb0, r = rok, n = listOkr, v = pct),
  function(r, n, v) pkde1d(v, ddf$kde[ddf$r == r & ddf$n == n][[1]])
  )
wyb0$reqSwingQ <- pmap_dbl(transmute(wyb0, r = rok, n = listOkr, v = pct + reqSwing),
  function(r, n, v) pkde1d(v, ddf$kde[ddf$r == r & ddf$n == n][[1]])
  )
wyb0$reqSwingP <- qnorm(wyb0$reqSwingQ) - qnorm(wyb0$ecdfV)
wyb0$reqSwingL <- logit(wyb0$reqSwingQ) - logit(wyb0$ecdfV)
wyb0$reqSwingQ <- identity(wyb0$reqSwingQ) - identity(wyb0$ecdfV)

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "CREATE TEMPORARY TABLE gerry.gerryWyborySwing (
  rok varchar(6), gmina varchar(6), okreg int, lista int, ecdfV double,
  reqSwing double, reqSwingQ double, reqSwingP double, reqSwingL double,
  PRIMARY KEY (rok, gmina, okreg, lista)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;")
sqlSaveBulk(hdbc, select(wyb0, -listOkr, -pct), "gerry.gerryWyborySwing")
sqlQuery(hdbc, "UPDATE gerry.gerryWyborySwing SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
  INNER JOIN gerry.gerryWyborySwing AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.okreg = q.okreg AND g.lista = q.lista
  SET g.ecdfV = q.ecdfV, g.reqSwing = q.reqSwing, g.reqSwingQ = q.reqSwingQ, g.reqSwingP = q.reqSwingP, g.reqSwingL = q.reqSwingL;")
