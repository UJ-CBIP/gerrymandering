require(scales)
require(ggpubr)

hdbc <- odbcConnect("cbip")
krk <- sqlQuery(hdbc, "SELECT id, IF(SUM(winPis) BETWEEN 19 AND 24, 'biased', 'random') AS alg,
  SUM(pis) / SUM(glos) AS pis, SUM(po) / SUM(glos) AS po, SUM(winPis) AS sPis, 43 - SUM(winPis) AS sPo,
  sv1.c AS svDirichlet, sv2.c AS svKernel, sv3.c AS svOutlier, bias1.c AS biasL1, bias2.c AS biasL2,
  gap1.c AS gap1, gap2.c AS gap2, gap3.c AS gap3, gap4.c AS gap4, mal1.c AS mal1, mal2.c AS mal2, eta.c AS eta
FROM (
  SELECT id, alg, okreg, SUM(pis) AS pis, SUM(po) AS po, SUM(glos) AS glos, IF(SUM(pis) > SUM(po), 1, 0) AS winPis
  FROM gerry.krakow GROUP BY id, okreg
) AS x
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVDirichlet' GROUP BY g.gmina ORDER BY gmina
) AS sv1 ON x.id = sv1.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVKernel' GROUP BY g.gmina ORDER BY gmina
) AS sv2 ON x.id = sv2.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVOutlier' GROUP BY g.gmina ORDER BY gmina
) AS sv3 ON x.id = sv3.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'BiasL1' GROUP BY g.gmina ORDER BY gmina
) AS bias1 ON x.id = bias1.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'BiasL2' GROUP BY g.gmina ORDER BY gmina
) AS bias2 ON x.id = bias2.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGap' GROUP BY g.gmina ORDER BY gmina
) AS gap1 ON x.id = gap1.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapThold' GROUP BY g.gmina ORDER BY gmina
) AS gap2 ON x.id = gap2.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapMid12' GROUP BY g.gmina ORDER BY gmina
) AS gap3 ON x.id = gap3.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapPotLad' GROUP BY g.gmina ORDER BY gmina
) AS gap4 ON x.id = gap4.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'MWETurnout' GROUP BY g.gmina ORDER BY gmina
) AS mal1 ON x.id = mal1.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'MWEPop' GROUP BY g.gmina ORDER BY gmina
) AS mal2 ON x.id = mal2.gmina
LEFT JOIN (
  SELECT g.gmina, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'Monotonicity' GROUP BY g.gmina ORDER BY gmina
) AS eta ON x.id = eta.gmina
GROUP BY x.id ORDER BY x.id;")

plot1 <- ggplot(krk, aes(x = sPis, y = svDirichlet + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(P)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")
plot2 <- ggplot(krk, aes(x = sPis, y = svKernel + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(Phi)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")
plot3 <- ggplot(krk, aes(x = sPis, y = svOutlier + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(U)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")
plot4 <- ggplot(krk, aes(x = sPis, y = biasL1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(B)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")
plot5 <- ggplot(krk, aes(x = sPis, y = gap1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(omega)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")
plot6 <- ggplot(krk, aes(x = sPis, y = mal1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(H)) + scale_x_continuous(n.breaks=8) +
  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7, limits = c(1, 2982)) +
  theme(legend.position = "none")

ggarrange(plot1, plot2, plot3, plot4, plot5, plot6, nrow = 3, ncol = 2)

krk0 <- sqlQuery(hdbc, "SELECT id, IF(SUM(winPis) BETWEEN 19 AND 24, 'biased', 'random') AS alg,
  SUM(pis) / SUM(glos) AS pis, SUM(po) / SUM(glos) AS po, SUM(winPis) AS sPis, 43 - SUM(winPis) AS sPo,
  sv1.value AS svDirichlet, sv2.value AS svKernel, sv3.value AS svOutlier,
  bias1.value AS biasL1, bias2.value AS biasL2,
  gap1.value AS gap1, gap2.value AS gap2, gap3.value AS gap3, gap4.value AS gap4,
  mal1.value AS mal1, mal2.value AS mal2, eta.value AS eta
FROM (
  SELECT id, alg, okreg, SUM(pis) AS pis, SUM(po) AS po, SUM(glos) AS glos, IF(SUM(pis) > SUM(po), 1, 0) AS winPis
  FROM gerry.krakow GROUP BY id, okreg
) AS x
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVDirichlet' GROUP BY g.gmina ORDER BY gmina
) AS sv1 ON x.id = sv1.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVKernel' GROUP BY g.gmina ORDER BY gmina
) AS sv2 ON x.id = sv2.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'SVOutlier' GROUP BY g.gmina ORDER BY gmina
) AS sv3 ON x.id = sv3.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'BiasL1' GROUP BY g.gmina ORDER BY gmina
) AS bias1 ON x.id = bias1.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'BiasL2' GROUP BY g.gmina ORDER BY gmina
) AS bias2 ON x.id = bias2.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGap' GROUP BY g.gmina ORDER BY gmina
) AS gap1 ON x.id = gap1.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapThold' GROUP BY g.gmina ORDER BY gmina
) AS gap2 ON x.id = gap2.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapMid12' GROUP BY g.gmina ORDER BY gmina
) AS gap3 ON x.id = gap3.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'EffGapPotLad' GROUP BY g.gmina ORDER BY gmina
) AS gap4 ON x.id = gap4.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'MWETurnout' GROUP BY g.gmina ORDER BY gmina
) AS mal1 ON x.id = mal1.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'MWEPop' GROUP BY g.gmina ORDER BY gmina
) AS mal2 ON x.id = mal2.gmina
LEFT JOIN (
  SELECT g.gmina, g.value, COUNT(x.gmina) AS c FROM gerry.gerrySuspects AS g
  LEFT JOIN gerry.gerrySuspects AS x ON x.rok = 2014 AND x.indicator = g.indicator AND x.skip = 0 AND
  IF(x.incr = 1, 1, -1) * x.value >= IF(g.incr = 1, 1, -1) * g.value
  WHERE g.rok = 9999 AND g.indicator = 'Monotonicity' GROUP BY g.gmina ORDER BY gmina
) AS eta ON x.id = eta.gmina
GROUP BY x.id ORDER BY x.id;")

plot1 <- ggplot(krk0, aes(x = sPis, y = svDirichlet + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(P)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")
plot2 <- ggplot(krk0, aes(x = sPis, y = svKernel + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(Phi)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")
plot3 <- ggplot(krk0, aes(x = sPis, y = svOutlier + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(U)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")
plot4 <- ggplot(krk0, aes(x = sPis, y = biasL1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(B)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")
plot5 <- ggplot(krk0, aes(x = sPis, y = gap1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(omega)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")
plot6 <- ggplot(krk0, aes(x = sPis, y = mal1 + 1, col = alg)) + geom_point() +
  stat_summary(fun=mean, aes(group=1), geom="line", colour="black") +
  xlab(expression(s[PiS])) + ylab(expression(H)) + scale_x_continuous(n.breaks=8) +
  #  scale_y_continuous(trans='log', labels = label_number(3), n.breaks=7) +
  theme(legend.position = "none")

ggarrange(plot1, plot2, plot3, plot4, plot5, plot6, nrow = 3, ncol = 2)
