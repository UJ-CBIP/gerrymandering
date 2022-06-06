SELECT id, alg, SUM(pis) / SUM(glos) AS pis, SUM(po) / SUM(glos) AS po, SUM(winPis) AS sPis, 43 - SUM(winPis) AS sPo,
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
GROUP BY x.id ORDER BY x.id LIMIT 500