require(DBI)
require(dplyr)
require(ggplot2)
require(GGally)
require(ggpubr)

hdbc <- odbcConnect("cbip", case="nochange")

# Figure 4

ggplot(gdf14, aes(x=v, y=avgThold)) +
  geom_point(aes(size=okr / cGmina, col=s)) +
  scale_size(range=c(0.1, 1)) +
  scale_color_gradient2(high="green", low="red", mid="blue", midpoint=0.2675) +
  labs(y = "t", size = "c", color = "s") + theme(legend.position = "top")

# Figure 5

ggplot(gdf14, aes(x=v, y=avgThold)) +
  geom_point(aes(size=okr / cGmina, col=npMeanS)) +
  scale_size(range=c(0.1, 1)) +
  scale_color_gradient2(high="green", low="red", mid="blue", midpoint=0.2675) +
  labs(y = "t", size = "c", color = "s") + theme(legend.position = "top")

# Figure 6

# Figure 7

# Figure 8

ggplot(filter(gdf14, okr > 0), aes(normV, s, col = uq + 1, size=(okr / cGmina)^2)) +
  geom_point() + xlab(expression(lambda)) +
  scale_size(range = c(1/5, 1)) +
  scale_color_gradient2(high="darkblue", mid="blue", low="red", midpoint=4.4, trans="log", labels = scales::number_format(accuracy = 1)) +
  theme(legend.title = element_blank()) +
  theme(legend.position="top", legend.key.width=unit(1,"cm"))

# Figure 9

ggplot(filter(gdf14, okr > 0), aes(normV, s, col = uqNorm + 1, size=(okr / cGmina)^2)) +
  geom_point() + xlab(expression(lambda)) +
  scale_size(range = c(1/5, 1)) +
  scale_color_gradient2(high="darkblue", mid="blue", low="red", midpoint=4.4, trans="log", labels = scales::number_format(accuracy = 1)) +
  theme(legend.title = element_blank()) +
  theme(legend.position="top", legend.key.width=unit(1,"cm"))

# Figure 10

marginDF <- sqlQuery(hdbc, "SELECT g1.rok, g1.gmina, g1.nazwa, g1.lista, g1.mandatow - g2.mandatow AS sDiff, w.margin FROM gerry.gerry AS g1
  INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.rankS = 2
  INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina, lista ORDER BY zw - runUp DESC) AS mrank,
    zw - runUp AS margin
    FROM gerry.gerryWybory WHERE mandat = 1
  ) AS w ON g1.rok = w.rok AND g1.gmina = w.gmina AND g1.lista = w.lista AND w.mrank = g1.mandatow - g2.mandatow
  WHERE g1.rok != 9999 AND g1.rankS = 1 ORDER BY sDiff DESC;")
lplot <- ggplot(filter(wyb, mandat==1), aes(x = (zw - runUp) / 1)) +
  geom_density() + xlab(expression(m[k])) + xlim(0, 500) + theme(axis.title.y=element_blank())
rplot <- ggplot(marginDF, aes(x = margin)) +
  geom_density() + xlab(expression(M)) + xlim(0, 500) + theme(axis.title.y=element_blank())
ggarrange(lplot, rplot)

# Figure 11

pvcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(pValue))
nvcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(phi))
uwcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(uqNorm))
g12 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(pvcdf(pValue)), qnorm(nvcdf(phi)), col=s)) + geom_point(size=0.7)
g21 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(nvcdf(phi)), qnorm(pvcdf(pValue)), col=s)) + geom_point(size=0.7)
g13 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(pvcdf(pValue)), qnorm(uwcdf(uqNorm)), col=s)) + geom_point(size=0.7)
g31 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(uwcdf(uqNorm)), qnorm(pvcdf(pValue)), col=s)) + geom_point(size=0.7)
g23 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(nvcdf(phi)), qnorm(uwcdf(uqNorm)), col=s)) + geom_point(size=0.7)
g32 <- ggplot(filter(gdf14, okr >= cGmina / 2), aes(qnorm(uwcdf(uqNorm)), qnorm(nvcdf(phi)), col=s)) + geom_point(size=0.7)
g11 <- ggplot(gdf14) + geom_density(mapping = aes(pValue), size=1.1)
g22 <- ggplot(gdf14) + geom_density(mapping = aes(phi), size=1.1)
g33 <- ggplot(gdf14) + geom_density(mapping = aes(uqNorm), size=1.1)
ggmatrix(list(g11, g12, g13, g21, g22, g23, g31, g32, g33), 3, 3,
         xAxisLabels = c("P", "Phi", "u"),
         yAxisLabels = c("P", "Phi", "u"),
         byrow = FALSE,
         title = NULL, xlab = NULL, ylab = NULL,
         showYAxisPlotLabels = FALSE, showXAxisPlotLabels = FALSE
        )

# Figure 12

dbcon <- dbConnect(odbc::odbc(), "cbip", timeout = 300)
suspects <- dbGetQuery(dbcon, "SELECT * FROM gerry.suspects")
suspects <- rename(suspects, P = svDirichlet, phi = svKernel, u = svOutlier)
pcdf <- with(filter(suspects, gcUnopp <= 5), ecdf(P))
ncdf <- with(filter(suspects, gcUnopp <= 5), ecdf(phi))
ucdf <- with(filter(suspects, gcUnopp <= 5), ecdf(u))
bcdf <- with(filter(suspects, gcUnopp <= 5), ecdf(biasL1))
g12 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(pcdf(P)), qnorm(ncdf(phi)), col=komGmina)) + geom_point(size=0.7)
g21 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(ncdf(phi)), qnorm(pcdf(P)), col=komGmina)) + geom_point(size=0.7)
g13 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(pcdf(P)), qnorm(ucdf(u)), col=komGmina)) + geom_point(size=0.7)
g31 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(ucdf(u)), qnorm(pcdf(P)), col=komGmina)) + geom_point(size=0.7)
g14 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(pcdf(P)), qnorm(bcdf(biasL1)), col=komGmina)) + geom_point(size=0.7)
g41 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(bcdf(biasL1)), qnorm(pcdf(P)), col=komGmina)) + geom_point(size=0.7)
g23 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(ncdf(phi)), qnorm(ucdf(u)), col=komGmina)) + geom_point(size=0.7)
g32 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(ucdf(u)), qnorm(ncdf(phi)), col=komGmina)) + geom_point(size=0.7)
g24 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(ncdf(phi)), qnorm(bcdf(biasL1)), col=komGmina)) + geom_point(size=0.7)
g42 <- ggplot(filter(suspects, gcUnopp <= 5), aes(qnorm(bcdf(biasL1)), qnorm(ncdf(phi)), col=komGmina)) + geom_point(size=0.7)
g11 <- ggplot(suspects) + geom_density(mapping = aes(P), size=1.1)
g22 <- ggplot(suspects) + geom_density(mapping = aes(phi), size=1.1)
g33 <- ggplot(filter(suspects, !is.na(u))) + geom_density(mapping = aes(u), size=1.1)
g44 <- ggplot(filter(suspects, !is.na(biasL1))) + geom_density(mapping = aes(biasL1), size=1.1)
ggmatrix(list(g11, g12, g13, g21, g22, g23, g31, g32, g33), 3, 3,
         xAxisLabels = c("P", "Phi", "u"),
         yAxisLabels = c("P", "Phi", "u"),
         title = NULL, xlab = NULL, ylab = NULL, byrow=FALSE,
         showYAxisPlotLabels = FALSE, showXAxisPlotLabels = FALSE
)
