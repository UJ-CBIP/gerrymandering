hdbc <- odbcConnect("cbip", case="nochange")
effGap <- sqlQuery(hdbc, "SELECT g1.rok, g1.gmina,
  g1.gap2 AS effGap1, g2.gap2 AS effGap2, g3.gap2 AS effGap3, g4.gap2 AS effGap4,
  g1.gap AS effGapV1, g2.gap AS effGapV2, g3.gap AS effGapV3, g4.gap AS effGapV4,
  g1.v2 / g1.v1 AS ratio, x.* FROM gerry.gerryEffGap AS g1
INNER JOIN gerry.gerryEffGap AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista1 = g1.lista1 AND g2.lista2 = g1.lista2 AND g2.method = 12
INNER JOIN gerry.gerryEffGap AS g3 ON g3.rok = g1.rok AND g3.gmina = g1.gmina AND g3.lista1 = g1.lista1 AND g3.lista2 = g1.lista2 AND g3.method = 13
INNER JOIN gerry.gerryEffGap AS g4 ON g4.rok = g1.rok AND g4.gmina = g1.gmina AND g4.lista1 = g1.lista1 AND g4.lista2 = g1.lista2 AND g4.method = 4
INNER JOIN gerry.gminy AS x ON x.rok = g1.rok AND x.gmina = g1.gmina
WHERE g1.rank1 = 1 AND g1.rank2 = 2 AND g1.method = 11;")

# INNER JOIN gerry.gerryBias AS i ON i.rok = x.rok AND i.gmina = x.gmina AND i.lista1 = x.lista1 AND i.lista2 = x.lista2 AND i.method = 'probit' AND i.c >= 8

suspects <- sqlQuery(hdbc, "SELECT * FROM gerry.suspects")
effGap2 <- inner_join(effGap, suspects)

ggplot(filter(effGap2, ratio > 1 / 3, !is.na(effGap)), aes(svDirichlet, -effGap1)) + geom_point() +
  geom_point(mapping = aes(svDirichlet, -effGap2), col="red") +
  geom_point(mapping = aes(svDirichlet, -effGap3), col="blue") +
  geom_point(mapping = aes(svDirichlet, -effGap4), col="green")

g12 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap1, effGap2, col=ratio)) + geom_point(size=0.7)
g21 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap2, effGap1, col=ratio)) + geom_point(size=0.7)
g13 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap1, effGap3, col=ratio)) + geom_point(size=0.7)
g31 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap3, effGap1, col=ratio)) + geom_point(size=0.7)
g23 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap2, effGap3, col=ratio)) + geom_point(size=0.7)
g32 <- ggplot(filter(effGap2, ratio > 1 / 3), aes(effGap3, effGap2, col=ratio)) + geom_point(size=0.7)
g11 <- ggplot(filter(effGap2, ratio > 1 / 3)) + geom_density(mapping = aes(effGap1), size=1.1)
g22 <- ggplot(filter(effGap2, ratio > 1 / 3)) + geom_density(mapping = aes(effGap2), size=1.1)
g33 <- ggplot(filter(effGap2, ratio > 1 / 3)) + geom_density(mapping = aes(effGap3), size=1.1)
ggmatrix(list(g11, g12, g13, g21, g22, g23, g31, g32, g33), 3, 3,
         xAxisLabels = c("omega[1]", "omega[2]", "omega[3]"),
         yAxisLabels = c("omega[1]", "omega[2]", "omega[3]"),
         labeller = "label_parsed", byrow = FALSE,
         title = NULL, xlab = NULL, ylab = NULL,
         showYAxisPlotLabels = FALSE, showXAxisPlotLabels = FALSE
)
