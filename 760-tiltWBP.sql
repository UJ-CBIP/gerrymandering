UPDATE gerry.wbp INNER JOIN (
    SELECT rok, gmina, lista, obwod, SUM(share) OVER (PARTITION BY rok, gmina, lista ORDER BY share DESC) AS r FROM gerry.wbp
) AS x ON wbp.rok = x.rok AND wbp.gmina = x.gmina AND wbp.lista = x.lista AND wbp.obwod = x.obwod SET wbp.lorenzShare = x.r;

UPDATE gerry.wbp INNER JOIN (
    SELECT rok, gmina, lista, obwod, SUM(normTurnout) OVER (PARTITION BY rok, gmina, lista ORDER BY rankV ASC) AS r FROM gerry.wbp
) AS x ON wbp.rok = x.rok AND wbp.gmina = x.gmina AND wbp.lista = x.lista AND wbp.obwod = x.obwod SET wbp.lorenzPop = x.r;

UPDATE gerry.wbp INNER JOIN (
    SELECT rok, gmina, lista, obwod, rankV, lorenzPop,
        LEAD(lorenzPop, 1, 1) OVER (PARTITION BY rok, gmina, lista ORDER BY rankV ASC) AS popNext,
        CASE
            WHEN lorenzPop <= 0.5 THEN 1
            WHEN lorenzPop > 0.5 AND LAG(lorenzPop, 1, 0) OVER (PARTITION BY rok, gmina, lista ORDER BY rankV ASC) <= 0.5
                THEN (0.5 - LAG(lorenzPop, 1, 0) OVER (PARTITION BY rok, gmina, lista ORDER BY rankV ASC)) /
                    (lorenzPop - LAG(lorenzPop, 1, 0) OVER (PARTITION BY rok, gmina, lista ORDER BY rankV ASC))
            ELSE 0
        END AS topHalf
    FROM gerry.wbp
) AS x ON wbp.rok = x.rok AND wbp.gmina = x.gmina AND wbp.lista = x.lista AND wbp.obwod = x.obwod SET wbp.topHalf = x.topHalf;

UPDATE gerry.wbp AS w
INNER JOIN gerry.tiltKMeansWBP AS k ON w.rok = k.rok AND w.gmina = k.gmina AND w.lista = k.lista
SET w.cluster = IF(v >= (cluster1 + cluster2) / 2, 1, 0);

REPLACE INTO gerry.tiltWBP
SELECT rok, gmina, lista, 'H',
    SUM(topHalf * glos) / SUM(topHalf * turnout) AS pctTop,
    SUM((1 - topHalf) * glos) / SUM((1 - topHalf) * turnout) AS pctBtm,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM gerry.wbp GROUP BY rok, gmina, lista;

REPLACE INTO gerry.tiltWBP
SELECT rok, gmina, lista, 'C',
    SUM(cluster * glos) / SUM(cluster * turnout) AS pctTop,
    SUM((1 - cluster) * glos) / SUM((1 - cluster) * turnout) AS pctBtm,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM gerry.wbp GROUP BY rok, gmina, lista;

UPDATE gerry.tiltWBP SET tilt = ATAN2(pctTop, pctBtm) - PI() / 4;
UPDATE gerry.tiltWBP SET maxTilt = IF((pctTop + pctBtm) > 1, ATAN2(1, pctTop + pctBtm - 1), ATAN2(1, 0)) - PI() / 4;

UPDATE gerry.polarWBP AS p
INNER JOIN gerry.tiltWBP AS t ON t.rok = p.rok AND t.gmina = p.gmina AND t.lista = p.lista AND t.typ = 'C'
SET p.tiltCluster = t.tilt;

UPDATE gerry.polarWBP AS p
INNER JOIN gerry.tiltWBP AS t ON t.rok = p.rok AND t.gmina = p.gmina AND t.lista = p.lista AND t.typ = 'H'
SET p.tiltHalf = t.tilt;
