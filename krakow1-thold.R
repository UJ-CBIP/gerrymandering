require(dplyr)
require(class)
require(kknn)
require(ggpubr)
require(readr)

wyb99 <- filter(wyb, rok == 9999)
wyb99$thold <- NA
# wyb99[wyb99$listOkr == 2,]$thold <- 0.5
# wyb99[wyb99$listOkr == 3,]$thold <- with(subset(wyb99, listOkr==3), sqrt((2*elk - elk^2) / (5*elk - 1)^2) + (2*elk - 1)/(5*elk - 1))

# pgrid <- expand.grid(pct = seq(0.25, 0.5, 0.001), elk = seq(1, 3, 0.001))
# pgrid$knn <- round(kknn(round(subset(wyb, listOkr==4)$s) ~ ., dplyr::select(subset(wyb, listOkr==4), pct, elk), pgrid, k = 5)$fitted.values)
# decbound <- pgrid %>% group_by(elk) %>% summarize(bound = 0.5 * (min(pct * (2-knn)) + max(pct * (1-knn))))
# sspline <- smooth.spline(decbound$elk, decbound$bound, df = 12)
# wyb99[wyb$listOkr == 4,]$thold <- predict(sspline, wyb99[wyb99$listOkr == 4,]$elk)$y

# pgrid <- expand.grid(pct = seq(0.20, 0.5, 0.001), elk = seq(1, 4, 0.001))
# pgrid$knn <- round(kknn(round(subset(wyb, listOkr==5)$s) ~ ., dplyr::select(subset(wyb, listOkr==5), pct, elk), pgrid, k = 5)$fitted.values)
# decbound <- pgrid %>% group_by(elk) %>% summarize(bound = 0.5 * (min(pct * (2-knn)) + max(pct * (1-knn))))
# sspline <- smooth.spline(decbound$elk, decbound$bound, df = 12)
# wyb99[wyb99$listOkr == 5,]$thold <- predict(sspline, wyb99[wyb99$listOkr == 5,]$elk)$y

wyb99$thold[wyb99$listOkr > 5] <- with(subset(wyb99, listOkr>5), 0.5 - (elk - 1) / (2 * listOkr))
wyb99$predS <- with(wyb99, ifelse(pct >= thold, 1, 0))
aggregate(abs(wyb99$s - wyb99$predS), by=list(wyb99$listOkr), mean)

hdbc <- odbcConnect("cbip", case="nochange")

sqlQuery(hdbc, "CREATE TEMPORARY TABLE gerry.gerryVT (
  `rok` varchar(6) NOT NULL, `gmina` varchar(6) NOT NULL, `okreg` int NOT NULL, `lista` int NOT NULL,
  `thold` double DEFAULT NULL, `predS` double DEFAULT NULL,
  PRIMARY KEY (`rok`,`gmina`,`okreg`,`lista`)
)")
sqlSaveBulk(hdbc, select(wyb99, rok, gmina, okreg, lista, thold, predS), "gerry.gerryVT")
sqlQuery(hdbc, "UPDATE gerry.gerryVT SET gmina = LPAD(gmina, 6, '0');")

sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
  INNER JOIN gerry.gerryVT AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.okreg = q.okreg AND g.lista = q.lista
  SET g.thold = q.thold;")

sqlQuery(hdbc, "UPDATE gerry.gerry AS g
  INNER JOIN (SELECT rok, gmina, koalicja AS lista, AVG(thold) AS t FROM gerry.gerryWybory GROUP BY rok, gmina, koalicja) AS q
  ON g.rok = q.rok AND g.gmina = q.gmina AND g.lista = q.lista
  SET g.avgThold = q.t;")

sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS h
  INNER JOIN gerry.gerry AS g ON g.rok = h.rok AND g.gmina = h.gmina AND g.lista = h.lista
  SET h.avgThold = g.avgThold;")
