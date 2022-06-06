require(dplyr)
require(np)

source('D:/gerry/bulkSave.R')

bwdist0 <- npcdistbw(s ~ v + avgThold, data=subset(gdf14, okr == 23), bwmethod="cv.ls", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
bwdens0 <- npcdensbw(s ~ v + avgThold, data=subset(gdf14, okr == 23), bwmethod="cv.ml", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")
bwreg0 <- npregbw(s ~ v + avgThold, data=subset(gdf14, okr == 23), bwmethod="cv.aic", bwtype="adaptive_nn", cxkertype="gaussian", cykertype="gaussian")

hdbc <- odbcConnect("cbip", case="nochange")
bwdf <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryNPBW WHERE rok = 2014 AND model = 'svt' AND estim = 'cdf' AND x1 IS NOT NULL")
bwdfD <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryNPBW WHERE rok = 2014 AND model = 'svt' AND estim = 'dens' AND x1 IS NOT NULL")
bwdfR <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryNPBW WHERE rok = 2014 AND model = 'svt' AND estim = 'reg' AND x1 IS NOT NULL")

for (i in 1:14) {
  bwdist <- bwdist0
  bwdist$xbw[1] <- bwdf$x1[i]
  bwdist$xbw[2] <- bwdf$x2[i]
  bwdist$ybw <- bwdf$y[i]
  bwdens <- bwdens0
  bwdens$xbw[1] <- bwdfD$x1[i]
  bwdens$xbw[2] <- bwdfD$x2[i]
  bwdens$ybw <- bwdfD$y[i]
  bwreg <- bwreg0
  bwreg$bw[1] <- bwdfR$x1[i]
  bwreg$bw[2] <- bwdfR$x2[i]
  svDist <- with(filter(gdf14, okr >= i), npcdist(bwdist,
     txdat = cbind(v, avgThold), tydat = s,
     exdat = cbind(filter(h14, okr == i)$v, filter(h14, okr == i)$avgThold),
     eydat = filter(h14, okr == i)$s)
  )
  svDens <- with(filter(gdf14, okr >= i), npcdens(bwdens,
     txdat = cbind(v, avgThold), tydat = s,
     exdat = cbind(filter(h14, okr == i)$v, filter(h14, okr == i)$avgThold),
     eydat = filter(h14, okr == i)$s)
  )
  svMean <- with(filter(gdf14, okr >= i), npreg(bwreg,
     txdat = cbind(v, avgThold), tydat = s,
     exdat = cbind(filter(h14, okr == i)$v, filter(h14, okr == i)$avgThold))
  )
  h14$cdist[h14$okr == i] <- svDist$condist
  h14$cdens[h14$okr == i] <- svDens$condens
  h14$cmean[h14$okr == i] <- svMean$mean
  print(i)
}
for (i in 15:15) {
  bwdist <- bwdist0
  bwdist$xbw[1] <- bwdf$x1[i]
  bwdist$xbw[2] <- bwdf$x2[i]
  bwdist$ybw <- bwdf$y[i]
  bwdens <- bwdens0
  bwdens$xbw[1] <- bwdfD$x1[i]
  bwdens$xbw[2] <- bwdfD$x2[i]
  bwdens$ybw <- bwdfD$y[i]
  bwreg <- bwreg0
  bwreg$bw[1] <- bwdfR$x1[i]
  bwreg$bw[2] <- bwdfR$x2[i]
  svDist <- with(filter(gdf14, okr >= i), npcdist(bwdist,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h14, okr >= i)$v, filter(h14, okr >= i)$avgThold),
    eydat = filter(h14, okr >= i)$s)
  )
  svDens <- with(filter(gdf14, okr >= i), npcdens(bwdens,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h14, okr >= i)$v, filter(h14, okr >= i)$avgThold),
    eydat = filter(h14, okr >= i)$s)
  )
  svMean <- with(filter(gdf14, okr >= i), npreg(bwreg,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h14, okr >= i)$v, filter(h14, okr >= i)$avgThold))
  )
  h14$cdist[h14$okr >= i] <- svDist$condist
  h14$cdens[h14$okr >= i] <- svDens$condens
  h14$cmean[h14$okr >= i] <- svMean$mean
  print(i)
}

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryNP;")
sqlSaveBulk(hdbc, select(h14, rok, gmina, lista, shift, cmean, cdens, cdist), "gerry.gerryNP")
sqlQuery(hdbc, "UPDATE gerry.gerryNP SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
  INNER JOIN gerry.gerryNP AS np ON np.rok = g.rok AND np.gmina = g.gmina AND np.lista = g.lista AND np.shift = g.shift
  SET g.npMeanS = np.cmean, g.npDevS = g.s - np.cmean, g.npDistS = np.cdist, g.phi = LEAST(np.cdist, 1 - np.cdist);")
