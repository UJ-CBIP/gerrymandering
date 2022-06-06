require(dplyr)
require(np)

source('D:/gerry/bulkSave.R')

gdf99 <- subset(gdf, rok == "9999")
h99 <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryHypoSV WHERE rok = 9999")

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
  print(i)
  if (nrow(filter(h99, okr == i)) == 0) { next }
  svDist <- with(filter(gdf14, okr >= i), npcdist(bwdist,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h99, okr == i)$v, filter(h99, okr == i)$avgThold),
    eydat = filter(h99, okr == i)$s)
  )
  svDens <- with(filter(gdf14, okr >= i), npcdens(bwdens,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h99, okr == i)$v, filter(h99, okr == i)$avgThold),
    eydat = filter(h99, okr == i)$s)
  )
  svMean <- with(filter(gdf14, okr >= i), npreg(bwreg,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h99, okr == i)$v, filter(h99, okr == i)$avgThold))
  )
  h99$cdist[h99$okr == i] <- svDist$condist
  h99$cdens[h99$okr == i] <- svDens$condens
  h99$cmean[h99$okr == i] <- svMean$mean
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
    exdat = cbind(filter(h99, okr >= i)$v, filter(h99, okr >= i)$avgThold),
    eydat = filter(h99, okr >= i)$s)
  )
  svDens <- with(filter(gdf14, okr >= i), npcdens(bwdens,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h99, okr >= i)$v, filter(h99, okr >= i)$avgThold),
    eydat = filter(h99, okr >= i)$s)
  )
  svMean <- with(filter(gdf14, okr >= i), npreg(bwreg,
    txdat = cbind(v, avgThold), tydat = s,
    exdat = cbind(filter(h99, okr >= i)$v, filter(h99, okr >= i)$avgThold))
  )
  h99$cdist[h99$okr >= i] <- svDist$condist
  h99$cdens[h99$okr >= i] <- svDens$condens
  h99$cmean[h99$okr >= i] <- svMean$mean
  print(i)
}

hdbc <- odbcConnect("cbip", case="nochange")
sqlQuery(hdbc, "DELETE FROM gerry.gerryNP WHERE rok = 9999;")
sqlSaveBulk(hdbc, select(h99, rok, gmina, lista, shift, cmean, cdens, cdist), "gerry.gerryNP")
sqlQuery(hdbc, "UPDATE gerry.gerryNP SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS g
  INNER JOIN gerry.gerryNP AS np ON np.rok = g.rok AND np.gmina = g.gmina AND np.lista = g.lista AND np.shift = g.shift
  SET g.npMeanS = np.cmean, g.npDevS = g.s - np.cmean, g.npDistS = np.cdist, g.phi = LEAST(np.cdist, 1 - np.cdist)
  WHERE g.rok = 9999;")
