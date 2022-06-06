INSERT INTO gerry.gerryHypoWybory
SELECT w.rok, w.gmina, w.okreg, w.koalicja, w.glosow AS v0, seq.i - 10 AS shift, GREATEST(0, w.glosow + seq.i - 10) AS vShift, NULL AS s,
    IF(glosow = zw, runUp, zw) AS tc, IF(glosow = zw, GREATEST(tie - 1, 0), tieRunUp) AS tie, w.glosOkr - w.glosow + GREATEST(0, w.glosow + seq.i - 10) AS glosOkr
FROM gerry.gerryWybory AS w INNER JOIN common._seq AS seq ON seq.i BETWEEN 0 AND 20
WHERE w.listOkr > 1;

UPDATE gerry.gerryHypoWybory SET s = IF(vShift > tc, 1, IF(vShift = tc, 1 / (tie + 1), 0));

INSERT INTO gerry.gerryHypoSV
SELECT w.rok, w.gmina, w.lista, w.shift, NULL AS w, SUM(w.vShift) / SUM(w.glosOkr) AS v, NULL AS q, SUM(w.s) AS man, COUNT(*) AS okr,
    SUM(w.s) / COUNT(*) AS s, g.avgThold, NULL AS normV, NULL AS pLess, NULL AS pMore, NULL AS pExact, NULL AS pValue,
    NULL AS npMeanS, NULL AS npDevS, NULL AS npDistS, NULL AS phi,
    NULL AS up, NULL AS un, NULL AS u, NULL AS uNorm
FROM gerry.gerryHypoWybory AS w INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.lista
GROUP BY w.rok, w.gmina, w.lista, w.shift;

UPDATE gerry.gerryHypoSV SET w = EXP(-2*POWER(shift, 2)/POWER(5, 2));
