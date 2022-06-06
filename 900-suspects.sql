TRUNCATE TABLE gerry.gerrySuspects;

UPDATE gerry.gerry AS g INNER JOIN (
    SELECT h.rok, h.gmina, h.lista, SUM(h.pValue * w) / SUM(w) AS pValue, SUM(h.npMeanS * w) / SUM(w) AS npMeanS,
        SUM(h.npDevS * w) / SUM(w) AS npDevS, SUM(h.npDistS * w) / SUM(w) AS npDistS, SUM(h.phi * w) / SUM(w) AS phi,
        SUM(h.up * w) / SUM(w) AS up, SUM(h.un * w) / SUM(w) AS un, SUM(h.u * w) / SUM(w) AS u, SUM(h.uNorm * w) / SUM(w) AS uNorm
    FROM gerry.gerryHypoSV AS h
    WHERE h.shift = 0 GROUP BY h.rok, h.gmina, h.lista
) AS h ON h.rok = g.rok AND h.gmina = g.gmina AND h.lista = g.lista
SET g.pValue = h.pValue, g.npMeanS = h.npMeanS, g.npDevS = h.npDevS, g.npDistS = h.npDistS, g.phi = h.phi,
    g.uqPos = h.up, g.uqNeg = h.un, g.uq = h.u, g.uqNorm = h.uNorm;

REPLACE INTO gerry.gerrySuspects
SELECT rok, gmina, nazwa, 'SVDirichlet', EXP(SUM(gpct * LOG(pValue))) AS pValue,
    IF(gcUnopp > cGmina / 2, NULL, RANK() OVER (PARTITION BY rok, IF(gcUnopp > cGmina / 2, 1, 0) ORDER BY EXP(SUM(gpct * LOG(pValue))) ASC)) AS rnk,
    0 AS incr, IF(gcUnopp > cGmina / 2, 1, 0) AS skip, NULL, NULL
FROM (
    SELECT h.rok, h.gmina, h.lista, SUM(h.pValue * w) / SUM(w) AS pValue, gpct, nazwa, gcUnopp, cGmina FROM gerry.gerryHypoSV AS h
    INNER JOIN gerry.gerry AS g ON g.rok = h.rok AND g.gmina = h.gmina AND g.lista = h.lista
    GROUP BY h.rok, h.gmina, h.lista
) AS x GROUP BY rok, gmina HAVING pValue IS NOT NULL;

REPLACE INTO gerry.gerrySuspects
SELECT rok, gmina, nazwa, 'SVKernel', EXP(SUM(gpct * LOG(phi))) AS phi,
    IF(gcUnopp > cGmina / 2, NULL, RANK() OVER (PARTITION BY rok, IF(gcUnopp > cGmina / 2, 1, 0) ORDER BY EXP(SUM(gpct * LOG(phi))) ASC)) AS rnk,
    0 AS incr, IF(gcUnopp > cGmina / 2, 1, 0) AS skip, NULL, NULL
FROM (
    SELECT h.rok, h.gmina, h.lista, SUM(h.phi * w) / SUM(w) AS phi, gpct, nazwa, gcUnopp, cGmina FROM gerry.gerryHypoSV AS h
    INNER JOIN gerry.gerry AS g ON g.rok = h.rok AND g.gmina = h.gmina AND g.lista = h.lista
    GROUP BY h.rok, h.gmina, h.lista
) AS x GROUP BY rok, gmina HAVING phi IS NOT NULL;

REPLACE INTO gerry.gerrySuspects
SELECT rok, gmina, nazwa, 'SVOutlier', EXP(SUM(gpct * LOG(u))) AS u,
    IF(gcUnopp > cGmina / 2, NULL, RANK() OVER (PARTITION BY rok, IF(gcUnopp > cGmina / 2, 1, 0) ORDER BY EXP(SUM(gpct * LOG(u))) ASC)) AS rnk,
    0 AS incr, IF(gcUnopp > cGmina / 2, 1, 0) AS skip, NULL, NULL
FROM (
    SELECT h.rok, h.gmina, h.lista, SUM((h.uNorm + 1) * w) / SUM(w) AS u, gpct, nazwa, gcUnopp, cGmina FROM gerry.gerryHypoSV AS h
    INNER JOIN gerry.gerry AS g ON g.rok = h.rok AND g.gmina = h.gmina AND g.lista = h.lista
    GROUP BY h.rok, h.gmina, h.lista
) AS x GROUP BY rok, gmina HAVING u IS NOT NULL;

UPDATE gerry.gerryBias AS b
INNER JOIN gerry.gerry AS g ON g.rok = b.rok AND g.gmina = b.gmina AND g.lista = b.lista1
SET b.rank1 = g.rankGlos;

UPDATE gerry.gerryBias AS b
INNER JOIN gerry.gerry AS g ON g.rok = b.rok AND g.gmina = b.gmina AND g.lista = b.lista2
SET b.rank2 = g.rankGlos;

UPDATE gerry.gerryBiasEx AS b
INNER JOIN gerry.gerry AS g ON g.rok = b.rok AND g.gmina = b.gmina AND g.lista = b.lista1
SET b.rank1 = g.rankGlos;

UPDATE gerry.gerryBiasEx AS b
INNER JOIN gerry.gerry AS g ON g.rok = b.rok AND g.gmina = b.gmina AND g.lista = b.lista2
SET b.rank2 = g.rankGlos; 

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'BiasL1', AVG(l1 * SQRT(c)) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) ASC, AVG(l1 * SQRT(c)) DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryBias AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'BiasL2', AVG(l2 * SQRT(c)) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) ASC, AVG(l2 * SQRT(c)) DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryBias AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'BiasLInf', AVG(lInf * SQRT(c)) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) ASC, AVG(lInf * SQRT(c)) DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.c < okrGmina / 3, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryBias AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'EffGap', b.gap2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3, 1, 0) ASC, b.gap2 DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3 OR i.c < okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryEffGap AS b
INNER JOIN (
    SELECT rok, gmina, lista1, lista2, COUNT(*) AS c FROM gerry.gerryIntersect GROUP BY rok, gmina, lista1, lista2
) AS i ON i.rok = b.rok AND i.gmina = b.gmina AND i.lista1 = b.lista1 AND i.lista2 = b.lista2
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 AND b.method = 12 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'EffGapThold', b.gap2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3, 1, 0) ASC, b.gap2 DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3 OR i.c < okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryEffGap AS b
INNER JOIN (
    SELECT rok, gmina, lista1, lista2, COUNT(*) AS c FROM gerry.gerryIntersect GROUP BY rok, gmina, lista1, lista2
) AS i ON i.rok = b.rok AND i.gmina = b.gmina AND i.lista1 = b.lista1 AND i.lista2 = b.lista2
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 AND b.method = 12 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'EffGapMid12', b.gap2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3, 1, 0) ASC, b.gap2 DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3 OR i.c < okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryEffGap AS b
INNER JOIN (
    SELECT rok, gmina, lista1, lista2, COUNT(*) AS c FROM gerry.gerryIntersect GROUP BY rok, gmina, lista1, lista2
) AS i ON i.rok = b.rok AND i.gmina = b.gmina AND i.lista1 = b.lista1 AND i.lista2 = b.lista2
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 AND b.method = 11 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'EffGapPotLad', b.gap2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3, 1, 0) ASC, b.gap2 DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3 OR i.c < okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryEffGap AS b
INNER JOIN (
    SELECT rok, gmina, lista1, lista2, COUNT(*) AS c FROM gerry.gerryIntersect GROUP BY rok, gmina, lista1, lista2
) AS i ON i.rok = b.rok AND i.gmina = b.gmina AND i.lista1 = b.lista1 AND i.lista2 = b.lista2
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 AND b.method = 13 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'EffGapRelev', b.gap2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3, 1, 0) ASC, b.gap2 DESC) AS `rank`,
    1 AS incr, IF(gcUnopp > okrGmina / 2 OR b.v1 / b.v2 > 3 OR i.c < okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryEffGap AS b
INNER JOIN (
    SELECT rok, gmina, lista1, lista2, COUNT(*) AS c FROM gerry.gerryIntersect GROUP BY rok, gmina, lista1, lista2
) AS i ON i.rok = b.rok AND i.gmina = b.gmina AND i.lista1 = b.lista1 AND i.lista2 = b.lista2
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
WHERE b.rank1 = 1 AND b.rank2 = 2 AND b.method = 4 GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT m.rok, m.gmina, g.nazwa, 'MalBhattPop', m.bhatt AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2, 1, 0) ASC, m.bhatt DESC) AS `rank`,
    0 AS incr, IF(gcUnopp > okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.malapp AS m INNER JOIN gerry.gminy AS g ON g.rok = m.rok AND g.gmina = m.gmina AND m.upraw = 1;

REPLACE INTO gerry.gerrySuspects
SELECT m.rok, m.gmina, g.nazwa, 'MalBhattTurn', m.bhatt AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(gcUnopp > okrGmina / 2, 1, 0) ASC, m.bhatt DESC) AS `rank`,
    0 AS incr, IF(gcUnopp > okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.malapp AS m INNER JOIN gerry.gminy AS g ON g.rok = m.rok AND g.gmina = m.gmina AND m.upraw = 0;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'MWETurnout', SUM(ABS(entTurnout) * gpct) / SUM(gpct) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(g.gcUnopp > okrGmina / 2, 1, 0) ASC, SUM(ABS(entTurnout) * gpct) / SUM(gpct) DESC) AS `rank`,
    1 AS incr, IF(g.gcUnopp > okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerry AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'MWEPop', SUM(ABS(entPop) * gpct) / SUM(gpct) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(g.gcUnopp > okrGmina / 2, 1, 0) ASC, SUM(ABS(entPop) * gpct) / SUM(gpct) DESC) AS `rank`,
    1 AS incr, IF(g.gcUnopp > okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerry AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina
GROUP BY b.rok, b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT b.rok, b.gmina, g.nazwa, 'Monotonicity', b.eta AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IF(g.gcUnopp > okrGmina / 2, 1, 0) ASC, b.eta DESC) AS `rank`,
    1 AS incr, IF(g.gcUnopp > okrGmina / 2, 1, 0) AS skip, NULL, NULL
FROM gerry.gerryMonoGminy AS b
INNER JOIN gerry.gminy AS g ON g.rok = b.rok AND g.gmina = b.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT g.rok, g.gmina, g.nazwa, 'IncumPack', IFNULL((SUM(c) - COUNT(c)) / g.okrGmina, 0) AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY IFNULL((SUM(c) - COUNT(c)) / g.okrGmina, 0) DESC) AS `rank`,
    1 AS incr, 0 AS skip, NULL, NULL
FROM (
    SELECT rok, gmina, okreg, COUNT(*) AS c FROM gerry.gerryWybory
    WHERE ii = 1 AND tag != 'i' GROUP BY rok, gmina, okreg HAVING c > 1
) AS x RIGHT JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina
GROUP BY g.rok, g.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT g.rok, g.gmina, g.nazwa, 'PolarEsteban', x.esteban AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY x.esteban DESC) AS `rank`,
    1 AS incr, 0 AS skip, NULL, NULL
FROM (
    SELECT rok, gmina,
        IF(SUM(inkumbent) > 0, SUM(IF(inkumbent > 0, esteban, 0)), SUM(IF(winner > 0, esteban, 0))) AS esteban
    FROM gerry.polarWBP GROUP BY rok, gmina HAVING esteban > 0
) AS x INNER JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT g.rok, g.gmina, g.nazwa, 'PolarTiltHW', x.tiltHalf AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY x.tiltHalf DESC) AS `rank`,
    1 AS incr, 0 AS skip, NULL, NULL
FROM (
    SELECT rok, gmina,
        IF(SUM(inkumbent) > 0, SUM(IF(inkumbent > 0, tiltHalf, 0)), SUM(IF(winner > 0, tiltHalf, 0))) AS tiltHalf
    FROM gerry.polarWBP GROUP BY rok, gmina HAVING tiltHalf > 0
) AS x INNER JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT g.rok, g.gmina, g.nazwa, 'PolarTiltCW', x.tiltCluster AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY x.tiltCluster DESC) AS `rank`,
    1 AS incr, 0 AS skip, NULL, NULL
FROM (
    SELECT rok, gmina,
        IF(SUM(inkumbent) > 0, SUM(IF(inkumbent > 0, tiltCluster, 0)), SUM(IF(winner > 0, tiltCluster, 0))) AS tiltCluster
    FROM gerry.polarWBP GROUP BY rok, gmina HAVING tiltCluster > 0
) AS x INNER JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina;

REPLACE INTO gerry.gerrySuspects
SELECT g.rok, g.gmina, g.nazwa, 'PolarTilt', (x.tiltHalf + x.tiltClus) / 2 AS `value`,
    RANK() OVER (PARTITION BY rok ORDER BY (x.tiltHalf + x.tiltClus) / 2 DESC) AS `rank`,
    1 AS incr, 0 AS skip, NULL, NULL
FROM (
    SELECT rok, gmina,
        IF(SUM(inkumbent) > 0, SUM(IF(inkumbent > 0, tiltHalf, 0)), SUM(IF(winner > 0, tiltHalf, 0))) AS tiltHalf,
        IF(SUM(inkumbent) > 0, SUM(IF(inkumbent > 0, tiltCluster, 0)), SUM(IF(winner > 0, tiltCluster, 0))) AS tiltClus
    FROM gerry.polarWBP GROUP BY rok, gmina HAVING tiltHalf > 0
) AS x INNER JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina;

DELETE FROM gerry.gerrySuspects WHERE value IS NULL;

UPDATE gerry.gerrySuspects AS s INNER JOIN (
    SELECT rok, gmina, indicator,
        CUME_DIST() OVER (PARTITION BY rok, indicator, skip ORDER BY value * IF(incr = 1, 1, -1) DESC) AS ecdf
    FROM gerry.gerrySuspects
) AS x ON s.rok = x.rok AND s.gmina = x.gmina AND s.indicator = x.indicator
SET s.ecdf = x.ecdf WHERE s.skip = 0 AND s.incr != 2;

UPDATE gerry.gerrySuspects AS s INNER JOIN (
    SELECT rok, gmina, indicator,
        CUME_DIST() OVER (PARTITION BY IF(rok = '9999', '2014', rok), indicator, skip ORDER BY value * IF(incr = 1, 1, -1) DESC) AS ecdf
    FROM gerry.gerrySuspects
) AS x ON s.rok = x.rok AND s.gmina = x.gmina AND s.indicator = x.indicator
SET s.ecdf = x.ecdf WHERE s.skip = 0 AND s.rok = '9999' AND s.incr != 2;

DROP VIEW IF EXISTS gerry.suspects;

CREATE VIEW gerry.suspects AS
SELECT s1.rok, s1.gmina, s1.nazwa,
    s1.value AS svDirichlet, s1.ecdf AS svDirichlet_ecdf,
    s2.value AS svKernel,    s2.ecdf AS svKernel_ecdf,
    s3.value AS svOutlier,   s3.ecdf AS svOutlier_ecdf,
    s4.value AS biasL1,      s4.ecdf AS biasL1_ecdf,
    s5.value AS biasL2,      s5.ecdf AS biasL2_ecdf,
    s6.value AS biasLInf,    s6.ecdf AS biasLInf_ecdf,
    s7.value AS effGap,      s7.ecdf AS effGap_ecdf,
    s8.value AS effGapT,     s8.ecdf AS effGapT_ecdf,
    s9.value AS effGapM12,   s9.ecdf AS effGapM12_ecdf,
    s12.value AS effGapNorm, s12.ecdf AS effGapNorm_ecdf,
    s10.value AS malPop,     s10.ecdf AS malPop_ecdf,
    s11.value AS malTurnout, s11.ecdf AS malTurnout_ecdf,
    s13.value AS monotonic,  s13.ecdf AS monotonic_ecdf,
    s14.value AS iiPack,     s14.ecdf AS iiPack_ecdf,
    s15.value AS malBhattPop,s15.ecdf AS malBhattPop_ecdf,
    s16.value AS malBhattTrn,s16.ecdf AS malBhattTrn_ecdf,
    s17.value AS esteban,    s17.ecdf AS esteban_ecdf,
    s18.value AS tiltHalf,   s18.ecdf AS tiltHalf_ecdf,
    s19.value AS tiltClus,   s19.ecdf AS tiltClus_ecdf,
    s20.value AS konflikt,
    s21.value AS poprawki,
    s22.value AS skargi,
    s23.value AS psi0,       s23.ecdf AS psi0_ecdf,
    s24.value AS psi,        s24.ecdf AS psi_ecdf,
    s25.value AS intent,     s25.ecdf AS intent_ecdf,
    g.gcUnopp, g.komGmina, g.okrGmina, g.glosGmina, g.typ, g.typ2010
FROM gerry.gerrySuspects AS s1
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
LEFT JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'SVKernel' AND s2.skip = 0
LEFT JOIN gerry.gerrySuspects AS s3 ON s3.rok = s1.rok AND s3.gmina = s1.gmina AND s3.indicator = 'SVOutlier' AND s3.skip = 0
LEFT JOIN gerry.gerrySuspects AS s4 ON s4.rok = s1.rok AND s4.gmina = s1.gmina AND s4.indicator = 'BiasL1' AND s4.skip = 0
LEFT JOIN gerry.gerrySuspects AS s5 ON s5.rok = s1.rok AND s5.gmina = s1.gmina AND s5.indicator = 'BiasL2' AND s5.skip = 0
LEFT JOIN gerry.gerrySuspects AS s6 ON s6.rok = s1.rok AND s6.gmina = s1.gmina AND s6.indicator = 'BiasLInf' AND s6.skip = 0
LEFT JOIN gerry.gerrySuspects AS s7 ON s7.rok = s1.rok AND s7.gmina = s1.gmina AND s7.indicator = 'EffGap' AND s7.skip = 0
LEFT JOIN gerry.gerrySuspects AS s8 ON s8.rok = s1.rok AND s8.gmina = s1.gmina AND s8.indicator = 'EffGapThold' AND s8.skip = 0
LEFT JOIN gerry.gerrySuspects AS s9 ON s9.rok = s1.rok AND s9.gmina = s1.gmina AND s9.indicator = 'EffGapMid12' AND s9.skip = 0
LEFT JOIN gerry.gerrySuspects AS s10 ON s10.rok = s1.rok AND s10.gmina = s1.gmina AND s10.indicator = 'MWEPop' AND s10.skip = 0
LEFT JOIN gerry.gerrySuspects AS s11 ON s11.rok = s1.rok AND s11.gmina = s1.gmina AND s11.indicator = 'MWETurnout' AND s11.skip = 0
LEFT JOIN gerry.gerrySuspects AS s12 ON s12.rok = s1.rok AND s12.gmina = s1.gmina AND s12.indicator = 'EffGapNorm' AND s12.skip = 0
LEFT JOIN gerry.gerrySuspects AS s13 ON s13.rok = s1.rok AND s13.gmina = s1.gmina AND s13.indicator = 'Monotonicity' AND s13.skip = 0
LEFT JOIN gerry.gerrySuspects AS s14 ON s14.rok = s1.rok AND s14.gmina = s1.gmina AND s14.indicator = 'IncumPack' AND s14.skip = 0
LEFT JOIN gerry.gerrySuspects AS s15 ON s15.rok = s1.rok AND s15.gmina = s1.gmina AND s15.indicator = 'MalBhattPop' AND s15.skip = 0
LEFT JOIN gerry.gerrySuspects AS s16 ON s16.rok = s1.rok AND s16.gmina = s1.gmina AND s16.indicator = 'MalBhattTurn' AND s16.skip = 0
LEFT JOIN gerry.gerrySuspects AS s17 ON s17.rok = s1.rok AND s17.gmina = s1.gmina AND s17.indicator = 'PolarEsteban' AND s17.skip = 0
LEFT JOIN gerry.gerrySuspects AS s18 ON s18.rok = s1.rok AND s18.gmina = s1.gmina AND s18.indicator = 'PolarTiltHW' AND s18.skip = 0
LEFT JOIN gerry.gerrySuspects AS s19 ON s19.rok = s1.rok AND s19.gmina = s1.gmina AND s19.indicator = 'PolarTiltCW' AND s19.skip = 0
LEFT JOIN gerry.gerrySuspects AS s20 ON s20.rok = s1.rok AND s20.gmina = s1.gmina AND s20.indicator = 'CouncilIVC_F' AND s20.skip = 0
LEFT JOIN gerry.gerrySuspects AS s21 ON s21.rok = s1.rok AND s21.gmina = s1.gmina AND s21.indicator = 'CouncilAmend' AND s21.skip = 0
LEFT JOIN gerry.gerrySuspects AS s22 ON s22.rok = s1.rok AND s22.gmina = s1.gmina AND s22.indicator = 'Skargi' AND s22.skip = 0
LEFT JOIN gerry.gerrySuspects AS s23 ON s23.rok = s1.rok AND s23.gmina = s1.gmina AND s23.indicator = 'Psi0' AND s23.skip = 0
LEFT JOIN gerry.gerrySuspects AS s24 ON s24.rok = s1.rok AND s24.gmina = s1.gmina AND s24.indicator = 'Psi' AND s24.skip = 0
LEFT JOIN gerry.gerrySuspects AS s25 ON s25.rok = s1.rok AND s25.gmina = s1.gmina AND s25.indicator = 'Intent' AND s25.skip = 0
WHERE s1.indicator = 'SVDirichlet' AND s1.skip = 0;

REPLACE INTO gerry.gerrySuspects
SELECT rok, gmina, nazwa, 'Psi0', psi, RANK() OVER (PARTITION BY rok ORDER BY psi ASC) AS rnk,
    0 AS incr, 0 AS skip, CUME_DIST() OVER (PARTITION BY rok ORDER BY psi ASC) AS ecdf, NULL AS ncdf
FROM (
    SELECT rok, gmina, nazwa,
        (svDirichlet_ecdf + svKernel_ecdf + svOutlier_ecdf + IFNULL(biasL1_ecdf, 0) + IFNULL(effGap_ecdf, 0)) /
            (3 + IF(ISNULL(biasL1_ecdf), 0, 1) + IF(ISNULL(effGap_ecdf), 0, 1)) AS psi
    FROM gerry.suspects
) AS x;

REPLACE INTO gerry.gerrySuspects SELECT * FROM (
SELECT rok, gmina, nazwa, 'Psi0', psi, RANK() OVER (PARTITION BY IF(rok = '9999', '2014', rok) ORDER BY psi ASC) AS rnk,
    0 AS incr, 0 AS skip, CUME_DIST() OVER (PARTITION BY IF(rok = '9999', '2014', rok) ORDER BY psi ASC) AS ecdf, NULL AS ncdf
FROM (
    SELECT rok, gmina, nazwa,
        (svDirichlet_ecdf + svKernel_ecdf + svOutlier_ecdf + IFNULL(biasL1_ecdf, 0) + IFNULL(effGap_ecdf, 0)) /
            (3 + IF(ISNULL(biasL1_ecdf), 0, 1) + IF(ISNULL(effGap_ecdf), 0, 1)) AS psi
    FROM gerry.suspects
) AS x) AS xx WHERE rok = '9999';

REPLACE INTO gerry.gerrySuspects
SELECT rok, gmina, nazwa, 'Psi', psi, RANK() OVER (PARTITION BY rok ORDER BY psi ASC) AS rnk,
    0 AS incr, 0 AS skip, CUME_DIST() OVER (PARTITION BY rok ORDER BY psi ASC) AS ecdf, NULL AS ncdf
FROM (
    SELECT rok, gmina, nazwa, CASE
        WHEN psi0 <= IFNULL(monotonic_ecdf, 1) AND psi0 <= IFNULL(malTurnout_ecdf, 1) THEN psi0
        WHEN psi0 > IFNULL(monotonic_ecdf, 1) AND psi0 <= IFNULL(malTurnout_ecdf, 1) THEN (X*psi0 + IFNULL(monotonic_ecdf, 1)) / (X+1)
        WHEN psi0 > IFNULL(malTurnout_ecdf, 1) AND psi0 <= IFNULL(monotonic_ecdf, 1) THEN (X*psi0 + IFNULL(malTurnout_ecdf, 1)) / (X+1)
        WHEN psi0 > IFNULL(malTurnout_ecdf, 1) AND psi0 > IFNULL(monotonic_ecdf, 1) THEN (X*psi0 + IFNULL(malTurnout_ecdf, 1) + IFNULL(monotonic_ecdf, 1)) / (X+2)
    END AS psi FROM gerry.suspects INNER JOIN (SELECT 5 AS X) AS x
) AS x;

REPLACE INTO gerry.gerrySuspects SELECT * FROM (
SELECT rok, gmina, nazwa, 'Psi', psi AS psiVal, RANK() OVER (PARTITION BY IF(rok = '9999', '2014', rok) ORDER BY psi ASC) AS rnk,
    0 AS incr, 0 AS skip, CUME_DIST() OVER (PARTITION BY IF(rok = '9999', '2014', rok) ORDER BY psi ASC) AS ecdf, NULL AS ncdf
FROM (
    SELECT rok, gmina, nazwa, CASE
        WHEN psi0 <= IFNULL(monotonic_ecdf, 1) AND psi0 <= IFNULL(malTurnout_ecdf, 1) THEN psi0
        WHEN psi0 > IFNULL(monotonic_ecdf, 1) AND psi0 <= IFNULL(malTurnout_ecdf, 1) THEN (X*psi0 + IFNULL(monotonic_ecdf, 1)) / (X+1)
        WHEN psi0 > IFNULL(malTurnout_ecdf, 1) AND psi0 <= IFNULL(monotonic_ecdf, 1) THEN (X*psi0 + IFNULL(malTurnout_ecdf, 1)) / (X+1)
        WHEN psi0 > IFNULL(malTurnout_ecdf, 1) AND psi0 > IFNULL(monotonic_ecdf, 1) THEN (X*psi0 + IFNULL(malTurnout_ecdf, 1) + IFNULL(monotonic_ecdf, 1)) / (X+2)
    END AS psi FROM gerry.suspects INNER JOIN (SELECT 5 AS X) AS x
) AS x) AS xx WHERE rok = '9999';
