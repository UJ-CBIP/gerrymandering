require(dplyr)
require(class)
require(kknn)
require(ggpubr)
require(readr)

wyb$thold <- NA
wyb[wyb$listOkr == 2,]$thold <- 0.5
wyb[wyb$listOkr == 3,]$thold <- with(subset(wyb, listOkr==3), sqrt((2*elk - elk^2) / (5*elk - 1)^2) + (2*elk - 1)/(5*elk - 1))

pgrid <- expand.grid(pct = seq(0.25, 0.5, 0.001), elk = seq(1, 3, 0.001))
pgrid$knn <- round(kknn(round(subset(wyb, listOkr==4)$s) ~ ., dplyr::select(subset(wyb, listOkr==4), pct, elk), pgrid, k = 5)$fitted.values)
decbound <- pgrid %>% group_by(elk) %>% summarize(bound = 0.5 * (min(pct * (2-knn)) + max(pct * (1-knn))))
sspline <- smooth.spline(decbound$elk, decbound$bound, df = 12)
wyb[wyb$listOkr == 4,]$thold <- predict(sspline, wyb[wyb$listOkr == 4,]$elk)$y

pgrid <- expand.grid(pct = seq(0.20, 0.5, 0.001), elk = seq(1, 4, 0.001))
pgrid$knn <- round(kknn(round(subset(wyb, listOkr==5)$s) ~ ., dplyr::select(subset(wyb, listOkr==5), pct, elk), pgrid, k = 5)$fitted.values)
decbound <- pgrid %>% group_by(elk) %>% summarize(bound = 0.5 * (min(pct * (2-knn)) + max(pct * (1-knn))))
sspline <- smooth.spline(decbound$elk, decbound$bound, df = 12)
wyb[wyb$listOkr == 5,]$thold <- predict(sspline, wyb[wyb$listOkr == 5,]$elk)$y

wyb$thold[wyb$listOkr > 5] <- with(subset(wyb, listOkr>5), 0.5 - (elk - 1) / (2 * listOkr))
wyb$predS <- with(wyb, ifelse(pct >= thold, 1, 0))
aggregate(abs(wyb$s - wyb$predS), by=list(wyb$listOkr), mean)

hdbc <- odbcConnect("cbip", case="nochange")

sqlQuery(hdbc, "CREATE TEMPORARY TABLE gerry.gerryVT (
  `rok` varchar(6) NOT NULL, `gmina` varchar(6) NOT NULL, `okreg` int NOT NULL, `lista` int NOT NULL,
  `thold` double DEFAULT NULL, `predS` double DEFAULT NULL,
  PRIMARY KEY (`rok`,`gmina`,`okreg`,`lista`)
)")
sqlSaveBulk(hdbc, select(wyb, rok, gmina, okreg, lista, thold, predS), "gerry.gerryVT")
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

# wykresy klasyfikacji

plot3 <- subset(wyb, listOkr==3) %>% ggplot(aes(x=pct, y=elk, color=factor(round(s)))) + geom_point() + xlim(0.2, 0.5) + labs(color = "s", x = "v", y = expression(varphi))
plot4 <- subset(wyb, listOkr==4) %>% ggplot(aes(x=pct, y=elk, color=factor(round(s)))) + geom_point() + xlim(0.2, 0.5) + labs(color = "s", x = "v", y = expression(varphi))
plot5 <- subset(wyb, listOkr==5) %>% ggplot(aes(x=pct, y=elk, color=factor(round(s)))) + geom_point() + xlim(0.2, 0.5) + labs(color = "s", x = "v", y = expression(varphi))
plot6 <- subset(wyb, listOkr==6) %>% ggplot(aes(x=pct, y=elk, color=factor(round(s)))) + geom_point() + xlim(0.2, 0.5) + labs(color = "s", x = "v", y = expression(varphi))

ggarrange(plot3, plot4, plot5, plot6, ncol=2, nrow=2, common.legend = TRUE, legend="bottom", labels=list("N = 3", "N = 4", "N = 5", "N = 6"), hjust=-4.9, vjust=c(1.8, 2))
