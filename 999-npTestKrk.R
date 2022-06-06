svDistKrkPis <- npcdist(svDistBW,
  txdat = select(gdf14, v), tydat = select(gdf14, s),
  exdat = rep(0.331506009, times=44),
  eydat = seq(0, 43, 1) / 43
  )
svDistKrkPo <- npcdist(svDistBW,
  txdat = select(gdf14, v), tydat = select(gdf14, s),
  exdat = rep(0.326404729, times=44),
  eydat = seq(0, 43, 1) / 43
)
svDistKrkOthers <- npcdist(svDistBW,
  txdat = select(gdf14, v), tydat = select(gdf14, s),
  exdat = c(0.133971796, 0.067293436, 0.039640413, 0.055459088, 0.045724529),
  eydat = c(0, 0, 0, 0, 0)
)
rtDistKrkPis <- npcdist(rtDistBW,
  txdat = select(gdf14, avgThold), tydat = select(gdf14, npDistS),
  exdat = rep(0.336296375, times=44),
  eydat = svDistKrkPis$condist
)
rtDistKrkPo <- npcdist(rtDistBW,
  txdat = select(gdf14, avgThold), tydat = select(gdf14, npDistS),
  exdat = rep(0.338453797, times=44),
  eydat = svDistKrkPo$condist
)
rtDistKrkOthers <- npcdist(rtDistBW,
  txdat = select(gdf14, avgThold), tydat = select(gdf14, npDistS),
  exdat = c(0.336157652, 0.313722743, 0.301525217, 0.308724339, 0.304365919),
  eydat = svDistKrkOthers$condist
)
phiPis <- ifelse(rtDistKrkPis$condist > 0.5, 1 - rtDistKrkPis$condist, rtDistKrkPis$condist)
phiPo  <- ifelse(rtDistKrkPo$condist > 0.5, 1 - rtDistKrkPo$condist, rtDistKrkPo$condist)
phiOth <- ifelse(rtDistKrkOthers$condist > 0.5, 1 - rtDistKrkOthers$condist, rtDistKrkOthers$condist)
