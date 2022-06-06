require(dplyr)
require(np)
require(class)
require(kknn)
require(ggplot2)

source('D:/gerry/bulkSave.R')

# dopasowanie modeli
svDensBW <- npcdensbw(s ~ v, data=gdf14, bwmethod="cv.ml", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
svDistBW <- npcdistbw(s ~ v, data=gdf14, bwmethod="cv.ls", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
svRegBW <- npregbw(s ~ v, data=gdf14, regtype="lc", bwmethod="cv.aic", bwtype="adaptive_nn", ckertype="gaussian")

# Wykres 2 - wykres gęstości
predf <- expand.grid(v = seq(0, 1, 0.005), s = seq(0, 1, 0.005))
svDens <- npcdens(svDensBW, txdat = select(gdf14, v), tydat = select(gdf14, s), exdat = select(predf, v), eydat = select(predf, s))
svDensDF <- data.frame(x = svDens$xeval, y = svDens$yeval, dens = svDens$condens)
ggplot(svDensDF, aes(x=v, y=s, color=dens)) + geom_point() + scale_color_gradient(trans = "sqrt") + theme(legend.title = element_blank())

predf <- expand.grid(v = seq(0, 1, 0.005), s = seq(0, 1, 0.005))
svDist <- npcdist(svDistBW, txdat = select(gdf14, v), tydat = select(gdf14, s), exdat = select(predf, v), eydat = select(predf, s))
svDistDF <- data.frame(x = svDist$xeval, y = svDist$yeval, dens = svDist$condist)
ggplot(svDistDF, aes(x=v, y=s, color=abs(dens - 0.5))) + geom_point() + scale_color_gradient() + theme(legend.title = element_blank())

# Wykres 3 - wykres krzywej S-V
predv <- data.frame(v = seq(0, 1, 0.001))
svReg <- npreg(svRegBW, txdat = select(gdf14, v), tydat = gdf14$s, exdat = predv)
predv$s <- svReg$mean
ggplot(gdf14, aes(x=v, y=s)) +
  geom_point(color='blue', aes(size=okr / cGmina)) + scale_size(range=c(0.1, 1)) +
  geom_path(aes(x = v, y = s), data=predv, color="red", size=2) +
  theme(legend.position = "none")

# do Wykresu 3 - estymacja pseudo-R^2
svRegT <- npreg(svRegBW, txdat = select(gdf14, v), tydat = gdf14$s, exdat = select(gdf14, v), eydat = gdf14$s)

svReg <- npreg(svRegBW, txdat = select(gdf14, v), tydat = gdf14$s, exdat = select(h14, v))
svDist <- npcdist(svDistBW, txdat = select(gdf14, v), tydat = select(gdf14, s), exdat = select(h14, v), eydat = select(h14, s))
svDens <- npcdens(svDensBW, txdat = select(gdf14, v), tydat = select(gdf14, s), exdat = select(h14, v), eydat = select(h14, s))
# svDistDF <- data.frame(x = svDens$xeval, y = svDens$yeval, dens = svDens$condens)
# ggplot(svDensDF, aes(x=v, y=s, color=dens)) + geom_point() + scale_color_gradient(low="blue", high="red", trans = "sqrt") + theme(legend.title = element_blank())

npdf <- filter(h14, !is.na(v)) %>% select(rok, gmina, lista, shift)
npdf$cmean <- svReg$mean
npdf$cdist <- svDist$condist
npdf$cdens <- svDens$condens

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryNPSV;")
sqlSaveBulk(hdbc, npdf, "gerry.gerryNPSV")
sqlQuery(hdbc, "UPDATE gerry.gerryNPSV SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
  INNER JOIN gerry.gerryNPSV AS np ON np.rok = g.rok AND np.gmina = g.gmina AND np.lista = g.lista AND np.shift = g.shift
  SET g.npMeanS = np.cmean, g.npDevS = g.s - np.cmean, g.npDistS = np.cdist;")

hypo <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryHypoSV")
h14 <- filter(hypo, rok == '2014')
h18 <- filter(hypo, rok == '2018')

rtDensBW <- npcdensbw(npDistS ~ avgThold, data=gdf14, bwmethod="cv.ml", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
rtDistBW <- npcdistbw(npDistS ~ avgThold, data=gdf14, bwmethod="cv.ls", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
rtRegBW <- npregbw(npDistS ~ avgThold, data=gdf14, bwmethod="cv.aic", bwtype="adaptive_nn", ckertype="gaussian")

# Wykres 4 - wykres gęstości
predf2 <- expand.grid(t = seq(0.15, 0.5, 0.001), rho = seq(0, 1, 0.005))
rtDens <- with(filter(gdf14, s > 0 && s < 1), npcdens(rtDensBW, txdat = avgThold, tydat = krnlCdS, exdat = select(predf2, t), eydat = select(predf2, rho)))
rtDensDF <- data.frame(x = rtDens$xeval, y = rtDens$yeval, dens = rtDens$condens)
# ggplot(rtDensDF, aes(x=t, y=rho, color=dens)) + geom_point() + scale_color_gradient(low="blue", high="red", trans = "sqrt") + theme(legend.title = element_blank())
ggplot(svDistDF, aes(x=v, y=s, color=abs(dens - 0.5))) + geom_point() + scale_color_gradient() + theme(legend.title = element_blank())

# Wykres 5 - wykres krzywej rho-t
predt <- data.frame(t = seq(0.15, 0.5, 0.001))
rtReg <- npreg(rtRegBW, txdat = select(gdf14, avgThold), tydat = gdf14$krnlCdS, exdat = predt)
predt$rho <- rtReg$mean
ggplot(gdf14, aes(x=avgThold, y=krnlCdS)) +
  geom_point(color='blue', aes(size=okr / cGmina)) + scale_size(range=c(0.1, 1)) +
  geom_path(aes(x = t, y = rho), data=predt, color="red", size=2) +
  theme(legend.position = "none")

rtReg <- npreg(rtRegBW, txdat = select(gdf14, avgThold), tydat = gdf14$npDistS, exdat = select(h14, avgThold))
rtDist <- npcdist(rtDistBW, txdat = select(gdf14, avgThold), tydat = select(gdf14, npDistS), exdat = select(h14, avgThold), eydat = select(h14, npDistS))
rtDens <- npcdens(rtDensBW, txdat = select(gdf14, avgThold), tydat = select(gdf14, npDistS), exdat = select(h14, avgThold), eydat = select(h14, npDistS))

npdf2 <- filter(h14, !is.na(v)) %>% select(rok, gmina, lista, shift)
npdf2$cmean <- rtReg$mean
npdf2$cdist <- rtDist$condist
npdf2$cdens <- rtDens$condens

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryNPRT;")
sqlSaveBulk(hdbc, npdf2, "gerry.gerryNPRT")
sqlQuery(hdbc, "UPDATE gerry.gerryNPRT SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
  INNER JOIN gerry.gerryNPRT AS np ON np.rok = g.rok AND np.gmina = g.gmina AND np.lista = g.lista AND np.shift = g.shift
  SET g.npMeanRho = np.cmean, g.npDevRho = g.npDistS - np.cmean, g.npDistRho = np.cdist, g.phi = LEAST(np.cdist, 1 - np.cdist);")
