REPLACE INTO gerry.gminy
SELECT w.rok, w.gmina, g.nazwa, CASE g.typ WHEN 'GM' THEN 1 WHEN 'GW' THEN 2 WHEN 'GMW' THEN 3 END, gg.typWyb,
    COUNT(DISTINCT w.koalicja) AS komGmina, COUNT(DISTINCT w.okreg) AS okrGmina, SUM(w.glosow) AS glosGmina,
    SUM(IF(w.listOkr = 1, 1, 0)) AS gcUnopp, NULL AS gvUnopp,
    SUM(IF(w.tag = 'i', w.ii, 0)) AS ii, SUM(IF(w.tag = 'p', w.ii, 0)) AS pi, SUM(w.ii) AS ai, IFNULL(xx.c, 0) AS iiPack,
    NULL, NULL, NULL, NULL, NULL AS elk, NULL AS compet, '' AS partisan, NULL AS partiaWladzy
FROM gerry.gerryWybory AS w
INNER JOIN wybory.gminy AS g ON g.teryt = w.gmina AND g.rok = w.rok
LEFT JOIN wybory.gminy AS gg ON gg.guid = g.guid AND gg.rok = 2010
LEFT JOIN (
    SELECT gmina, COUNT(*) AS c FROM (
        SELECT gmina, okreg, SUM(ii) AS ii, SUM(IF(tag = 'i', 1, 0)) AS i, SUM(IF(tag = 'i', 1, 0)) AS p
        FROM gerry.gerryWybory GROUP BY gmina, okreg HAVING ii - i > 1
    ) AS x GROUP BY gmina
) AS xx ON xx.gmina = w.gmina
GROUP BY w.rok, w.gmina;

UPDATE gerry.gminy AS g INNER JOIN (
    SELECT teryt, AVG(margin) AS margin FROM (
        SELECT w1.rok, w1.teryt, (w1.glos1tura - IFNULL(w2.glos1tura, w1.glos1przeciw)) / w1.sum1tura AS margin
        FROM wsmip.samWojt AS w1 LEFT JOIN wsmip.samWojt AS w2 ON w2.rok = w1.rok AND w2.teryt = w1.teryt AND w2.rank1 = 2
        WHERE w1.rank1 = 1
    ) AS xx GROUP BY teryt
) AS x ON g.gmina = x.teryt SET g.compet = x.margin;
