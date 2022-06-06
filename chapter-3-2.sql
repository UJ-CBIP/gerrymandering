SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(pValue * 100, 2), '%') AS P, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct, CONCAT(ROUND(q * 100, 2), '%') AS q,
    mandatow AS s, ROUND(expectS * okr, 2) AS expectS, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, ROUND(avgThold, 2) AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND pValue IS NOT NULL # AND gcUnopp <= 5 AND s < expectS
ORDER BY pValue ASC LIMIT 10;

SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(pValue * 100, 2), '%') AS P, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct, CONCAT(ROUND(q * 100, 2), '%') AS q,
    mandatow AS s, ROUND(expectS * okr, 2) AS expectS, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, ROUND(avgThold, 2) AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND pValue IS NOT NULL AND gcUnopp <= 5 AND s < expectS AND okr >= cGmina / 2
ORDER BY pValue ASC LIMIT 10
) AS x UNION SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(pValue * 100, 2), '%') AS P, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct, CONCAT(ROUND(q * 100, 2), '%') AS q,
    mandatow AS s, ROUND(expectS * okr, 2) AS expectS, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, ROUND(avgThold, 2) AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND pValue IS NOT NULL AND gcUnopp <= 5 AND s > expectS AND okr >= cGmina / 2
ORDER BY pValue ASC LIMIT 10
) AS x;

SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(phi * 100, 2), '%') AS Phi, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct,
    mandatow AS s, ROUND(npMeanS * okr, 2) AS expectS, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, CONCAT(ROUND(avgThold * 100), '%') AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND phi IS NOT NULL AND gcUnopp <= 5 AND npDistS < 0.5 AND okr >= cGmina / 2
ORDER BY phi ASC LIMIT 10
) AS x UNION SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(phi * 100, 2), '%') AS Phi, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct,
    mandatow AS s, ROUND(npMeanS * okr, 2) AS expectS, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, CONCAT(ROUND(avgThold * 100), '%') AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND phi IS NOT NULL AND gcUnopp <= 5 AND npDistS > 0.5 AND okr >= cGmina / 2
ORDER BY phi ASC LIMIT 10
) AS x;

SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(uqNorm, 2), ' ', IF(uqPos < uqNeg, '(+)', '(-)')) AS u, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct, CONCAT(ROUND(normV * 100, 2), '%') AS w,
    mandatow AS s, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, CONCAT(ROUND(avgThold * 100), '%') AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND uqNorm IS NOT NULL AND normV > 0 AND gcUnopp <= 5 AND uqPos >= uqNeg AND okr >= cGmina / 2
ORDER BY uqNorm ASC LIMIT 10
) AS x UNION SELECT * FROM (
SELECT gmina AS teryt, nazwa, lista, CONCAT(ROUND(uqNorm, 2), ' ', IF(uqPos < uqNeg, '(+)', '(-)')) AS u, okr AS c,
    CONCAT(ROUND(v * 100, 2), '%') AS v, CONCAT(ROUND(gpct * 100, 2), '%') AS gpct, CONCAT(ROUND(normV * 100, 2), '%') AS w,
    mandatow AS s, ROUND(avgComp, 2) AS n, ROUND(avgElk, 2) AS elk, CONCAT(ROUND(avgThold * 100), '%') AS t,
    CASE typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, typ2010, IFNULL(tag, '(-)') AS wojt
FROM gerry.gerry WHERE rok = '2014' AND uqNorm IS NOT NULL AND normV > 0 AND gcUnopp <= 5 AND uqPos < uqNeg AND okr >= cGmina / 2
ORDER BY uqNorm ASC LIMIT 10
) AS x;

SELECT s1.gmina AS teryt, g.nazwa AS gmina, g.typGminy AS typ, g.typ2010, ROUND(s1.value, 3) AS P, ROUND(s2.value, 3) AS phi, ROUND(s3.value, 2) AS u, g.komGmina, g.okrGmina, g.glosGmina
FROM gerry.gerrySuspects AS s1
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'SVKernel'
INNER JOIN gerry.gerrySuspects AS s3 ON s3.rok = s1.rok AND s3.gmina = s1.gmina AND s3.indicator = 'SVOutlier'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
WHERE s1.rok = 2014 AND s1.indicator = 'SVDirichlet' AND g.gcUnopp <= 5 AND s3.value IS NOT NULL ORDER BY s1.value ASC LIMIT 10;

SELECT s.gmina AS teryt, g.nazwa AS gmina, CASE g.typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, g.typ2010,
b.lista1, b.lista2, b.c,
    CONCAT(ROUND(b.v1 * 100, 2), ' %'), CONCAT(ROUND(b.v2 * 100, 2), ' %'), b.s1, b.s2,
    ROUND(b.lInf * b.c, 2) AS lInf, ROUND(b.l1 * b.c, 2) AS l1, ROUND(b.l1 * SQRT(b.c), 2) AS l1norm,
    g.komGmina, g.okrGmina, g.glosGmina
FROM gerry.gerrySuspects AS s
INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina
INNER JOIN gerry.gerryBias AS b ON b.rok = s.rok AND b.gmina = s.gmina AND b.method = 'probit' AND b.rank1 = 1 AND b.rank2 = 2
WHERE s.rok = '2014' AND s.indicator = 'BiasL1' AND s.skip = 0 AND s.value IS NOT NULL
ORDER BY l1norm DESC LIMIT 10;

SELECT g1.rok, g1.gmina, g1.nazwa, g1.lista, g1.mandatow - g2.mandatow AS sDiff, w.margin FROM gerry.gerry AS g1
INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.rankS = 2
INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina, lista ORDER BY zw - runUp DESC) AS mrank,
        zw - runUp AS margin
    FROM gerry.gerryWybory WHERE mandat = 1
) AS w ON g1.rok = w.rok AND g1.gmina = w.gmina AND g1.lista = w.lista AND w.mrank = g1.mandatow - g2.mandatow
WHERE g1.rok != 9999 AND g1.rankS = 1 ORDER BY sDiff DESC;