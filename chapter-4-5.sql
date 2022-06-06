SELECT s1.gmina AS teryt, g.nazwa AS gmina, g.typGminy AS typ, ROUND(s1.value, 3) AS P, ROUND(s2.value, 3) AS phi, ROUND(s3.value, 2) AS u,
    g.komGmina, ROUND(ss.value, 3) AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerrySuspects AS s1
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'SVKernel'
INNER JOIN gerry.gerrySuspects AS s3 ON s3.rok = s1.rok AND s3.gmina = s1.gmina AND s3.indicator = 'SVOutlier'
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = s1.gmina AND ss.indicator = s1.indicator
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s1.gmina AND psi.indicator = 'Psi'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
WHERE s1.rok = 2018 AND s1.indicator = 'SVDirichlet' AND g.gcUnopp <= 5 AND s3.value IS NOT NULL ORDER BY s1.value ASC LIMIT 10;

SELECT s1.gmina AS teryt, g.nazwa AS gmina, g.typGminy AS typ, ROUND(s1.value, 3) AS P, ROUND(s2.value, 3) AS phi, ROUND(s3.value, 2) AS u,
    g.komGmina, ROUND(ss.value, 3) AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerrySuspects AS s1
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'SVKernel'
INNER JOIN gerry.gerrySuspects AS s3 ON s3.rok = s1.rok AND s3.gmina = s1.gmina AND s3.indicator = 'SVOutlier'
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = s1.gmina AND ss.indicator = s2.indicator
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s1.gmina AND psi.indicator = 'Psi'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
WHERE s1.rok = 2018 AND s1.indicator = 'SVDirichlet' AND g.gcUnopp <= 5 AND s3.value IS NOT NULL ORDER BY s2.value ASC LIMIT 10;

SELECT s1.gmina AS teryt, g.nazwa AS gmina, g.typGminy AS typ, ROUND(s1.value, 3) AS P, ROUND(s2.value, 3) AS phi, ROUND(s3.value, 2) AS u,
    g.komGmina, ROUND(ss.value, 3) AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerrySuspects AS s1
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'SVKernel'
INNER JOIN gerry.gerrySuspects AS s3 ON s3.rok = s1.rok AND s3.gmina = s1.gmina AND s3.indicator = 'SVOutlier'
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = s1.gmina AND ss.indicator = s3.indicator
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s1.gmina AND psi.indicator = 'Psi'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
WHERE s1.rok = 2018 AND s1.indicator = 'SVDirichlet' AND g.gcUnopp <= 5 AND s3.value IS NOT NULL ORDER BY s3.value ASC LIMIT 10;

SELECT g.gmina AS teryt, x.nazwa AS gmina, x.typGminy AS typ, x.typ2010,
    g.lista1, g.lista2, CONCAT(ROUND(g.v1 * 100, 0), '%') AS v1, CONCAT(ROUND(g.v2 * 100, 0), '%') AS v2,
    ROUND(g.w1, 2) AS w1, ROUND(g.w2, 2) AS w2, REPLACE(ROUND(g.gap2, 3), '0.', '.') AS gap,
    REPLACE(ROUND(ss.value, 3), '0.', '.') AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerryEffGap AS g
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = g.gmina AND ss.indicator = 'EffGap'
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = g.gmina AND psi.indicator = 'Psi'
INNER JOIN gerry.gminy AS x ON x.rok = g.rok AND x.gmina = g.gmina
WHERE g.rok = 2018 AND g.rank1 = 1 AND g.rank2 = 2 AND g.method = 12 AND g.v1 / g.v2 < 12 AND x.gcUnopp <= 5
ORDER BY g.gap2 DESC LIMIT 10;

SELECT s1.gmina, g.nazwa, CONCAT(ROUND(s1.value * 1000, 2), 'E-3') AS H, ROUND(s2.value, 3) AS Delta,
    s2.rank, g.typ, g.komGmina, g.okrGmina - g.gcUnopp AS cPrime,
    CONCAT(ROUND(ss.value * 1000, 2), 'E-3') AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerrySuspects AS s1 
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'MalBhattTurn'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = s1.gmina AND ss.indicator = s1.indicator
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s1.gmina AND psi.indicator = 'Psi'
WHERE s1.indicator = 'MWETurnout' AND s1.rok = 2018
ORDER BY s1.value DESC LIMIT 10;

SELECT m.gmina, g.nazwa, ROUND(m.eta, 3) AS eta, m.cPairs, g.typ, g.komGmina,
    ROUND(ss.value, 3) AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerryMonoGminy AS m 
INNER JOIN gerry.gminy AS g ON g.rok = m.rok AND g.gmina = m.gmina
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = m.gmina AND ss.indicator = 'Monotonicity'
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = m.gmina AND psi.indicator = 'Psi'
WHERE m.rok = 2018
ORDER BY m.eta DESC LIMIT 10;

SELECT s.gmina AS teryt, g.nazwa AS gmina, CASE g.typGminy WHEN 1 THEN 'M' WHEN 2 THEN 'W' WHEN 3 THEN 'MW' END AS typ, b.lista1, b.lista2, b.c,
    CONCAT(ROUND(b.v1 * 100, 2), ' %') AS v1, CONCAT(ROUND(b.v2 * 100, 2), ' %') AS v2, b.s1, b.s2,
    ROUND(b.lInf * b.c, 3) AS lInf, ROUND(b.l1 * b.c, 3) AS l1, ROUND(b.l1 * SQRT(b.c), 3) AS l1norm,
    g.komGmina, ROUND(ss.value, 3) AS val2014, ss.rank AS rnk2014, psi.rank AS psiRank
FROM gerry.gerrySuspects AS s
INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina
INNER JOIN gerry.gerryBias AS b ON b.rok = s.rok AND b.gmina = s.gmina AND b.method = 'probit' AND b.rank1 = 1 AND b.rank2 = 2
INNER JOIN gerry.gerrySuspects AS ss ON ss.rok = 2014 AND ss.gmina = s.gmina AND ss.indicator = s.indicator
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s.gmina AND psi.indicator = 'Psi'
WHERE s.rok = '2018' AND s.indicator = 'BiasL1' AND s.skip = 0 AND s.value IS NOT NULL
ORDER BY l1norm DESC LIMIT 10;

SELECT s.gmina, s.nazwa, RPAD(ROUND(s.psi, 4), 6, '0') AS psi, g.typ, g.typ2010 AS sw,
    g.komGmina AS n, g.glosGmina AS v, g.gcUnopp AS bk, ROUND(g.elk, 3) AS elk,
    CONCAT(ROUND(x.v * 100, 1), '%') AS v, x.okr, x.mandatow - x.cUnopp AS s, ROUND(x.expectS * x.okr, 2) AS expectS, ROUND((x.mandatow - x.cUnopp) - x.expectS * x.okr, 2) AS deltaS,
    RPAD(ROUND(psi.value, 4), 6, '0') AS val2014, psi.rank AS psiRank,
    ROUND(i.s - i.expectS, 3) AS deltaI
FROM gerry.suspects AS s
INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina
LEFT JOIN gerry.gerry AS x ON x.rok = s.rok AND x.gmina = s.gmina AND x.rankMan = 1
LEFT JOIN gerry.gerry AS i ON i.rok = s.rok AND i.gmina = s.gmina AND i.tag = 'i'
INNER JOIN gerry.gerrySuspects AS psi ON psi.rok = 2014 AND psi.gmina = s.gmina AND psi.indicator = 'Psi'
WHERE s.rok = 2018 GROUP BY s.rok, s.gmina ORDER BY s.psi ASC LIMIT 10;

