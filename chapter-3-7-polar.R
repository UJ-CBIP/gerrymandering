hdbc <- odbcConnect("cbip", case="nochange")
polar <- sqlQuery(hdbc, "SELECT * FROM gerry.polarWBP WHERE rok = 2014")

# pvcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(pValue))
# nvcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(phi))
# uwcdf <- with(filter(gdf14, okr >= cGmina / 2), ecdf(uqNorm))
p12 <- ggplot(polar) + geom_point(aes(esteban, tiltHalf), size=0.7)
p21 <- ggplot(polar) + geom_point(aes(tiltHalf, esteban), size=0.7)
p13 <- ggplot(polar) + geom_point(aes(esteban, tiltCluster), size=0.7)
p31 <- ggplot(polar) + geom_point(aes(tiltCluster, esteban), size=0.7)
p23 <- ggplot(polar) + geom_point(aes(tiltHalf, tiltCluster), size=0.7)
p32 <- ggplot(polar) + geom_point(aes(tiltCluster, tiltHalf), size=0.7)
p11 <- ggplot(polar) + geom_density(aes(esteban), size=1.1)
p22 <- ggplot(polar) + geom_density(aes(tiltHalf), size=1.1)
p33 <- ggplot(polar) + geom_density(aes(tiltCluster), size=1.1)
ggmatrix(list(p11, p12, p13, p21, p22, p23, p31, p32, p33), 3, 3,
         xAxisLabels = c("Esteban-Ray", "tilt połówkowy", "tilt klastrowy"),
         yAxisLabels = c("Esteban-Ray", "tilt połówkowy", "tilt klastrowy"),
         byrow = FALSE,
         title = NULL, xlab = NULL, ylab = NULL,
         showYAxisPlotLabels = FALSE, showXAxisPlotLabels = FALSE
)