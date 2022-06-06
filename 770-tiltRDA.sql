UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, lista, okreg, SUM(okrNorm) OVER (PARTITION BY rok, gmina, koalicja ORDER BY dRank ASC) AS r FROM gerry.gerryWybory
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.lista = x.lista AND w.okreg = x.okreg SET w.lorenzPop = x.r;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, lista, okreg, dRank, lorenzPop,
        LEAD(lorenzPop, 1, 1) OVER (PARTITION BY rok, gmina, koalicja ORDER BY dRank ASC) AS popNext,
        CASE
            WHEN LEAD(lorenzPop, 1, 1) OVER (PARTITION BY rok, gmina, koalicja ORDER BY dRank ASC) <= 0.5 THEN 1
            WHEN LEAD(lorenzPop, 1, 1) OVER (PARTITION BY rok, gmina, koalicja ORDER BY dRank ASC) > 0.5 AND lorenzPop < 0.5
                THEN (0.5 - lorenzPop) / (LEAD(lorenzPop, 1, 1) OVER (PARTITION BY rok, gmina, koalicja ORDER BY dRank ASC) - lorenzPop)
            ELSE 0
        END AS topHalf
    FROM gerry.gerryWybory
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.lista = x.lista AND w.okreg = x.okreg SET w.topHalf = x.topHalf;

INSERT INTO gerry.tiltRDA
SELECT rok, gmina, koalicja, 'H',
    SUM(topHalf * glosow) / SUM(topHalf * glosOkr) AS pctTop,
    SUM((1 - topHalf) * glosow) / SUM((1 - topHalf) * glosOkr) AS pctBtm,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM gerry.gerryWybory GROUP BY rok, gmina, koalicja;

UPDATE gerry.tiltRDA SET tilt = ATAN2(pctTop, pctBtm) - PI() / 4;
UPDATE gerry.tiltRDA SET maxTilt = IF((pctTop + pctBtm) > 1, ATAN2(1, pctTop + pctBtm - 1), ATAN2(1, 0)) - PI() / 4;
