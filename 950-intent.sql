DROP VIEW IF EXISTS gerry.intent;

CREATE VIEW gerry.intent AS
SELECT x.gmina, x.nazwa,
    IF(p.gmina IS NULL AND IFNULL(y.mj, 0) = 0, IF(intent0 = 0, 0, intent0 + 1 - est + 1 - tilt - IFNULL(y.contraWBP, 0)), 0) AS intent,
    intent0 AS konflikt, ISNULL(p.gmina) AS podzialRda, IFNULL(y.contraWBP, 0) AS contraWBP, 0 AS map1to1
FROM (
    SELECT rok, gmina, nazwa, IFNULL(konflikt, 0) + IFNULL(poprawki, 0) + IFNULL(skargi, 0) + IFNULL(iiPack, 0) / 4 AS intent0,
        esteban_ecdf AS est, (tiltHalf_ecdf + tiltClus_ecdf) / 2 AS tilt
    FROM gerry.suspects WHERE rok = 2014
) AS x LEFT JOIN gerry.postanowienia AS p ON p.gmina = x.gmina
LEFT JOIN (
    SELECT g.gmina, 1 AS contraWBP, IF(g.ii > g.cGmina / 2, 1, 0) AS mj FROM gerry.gerry AS g WHERE g.rok = 2014 AND g.tag = 'i' AND (g.s < g.expectS * 0.95)
) AS y ON y.gmina = x.gmina
ORDER BY intent DESC;

REPLACE INTO gerry.gerrySuspects
SELECT '2014' AS rok, LPAD(gmina, 6, '0') AS gmina, nazwa, 'Intent', intent AS `value`,
    RANK() OVER (ORDER BY intent DESC) AS `rank`, 1 AS incr, 0 AS skip, NULL, NULL
FROM gerry.intent;

UPDATE gerry.gerrySuspects AS s INNER JOIN (
    SELECT rok, gmina, indicator,
        CUME_DIST() OVER (PARTITION BY rok, indicator, skip ORDER BY value * IF(incr = 1, 1, -1) DESC) AS ecdf
    FROM gerry.gerrySuspects WHERE indicator = 'Intent'
) AS x ON s.rok = x.rok AND s.gmina = x.gmina AND s.indicator = x.indicator
SET s.ecdf = x.ecdf WHERE s.indicator = 'Intent';

SELECT psi.gmina, psi.nazwa, GREATEST(psi.rank, i.rank) AS rnk,
    psi.rank AS r_psi, ROUND(psi.value, 3) AS psi, i.rank AS r_theta, ROUND(i.value, 2) AS theta,
    g.typ, g.typ2010 AS sw, g.komGmina AS n, g.okrGmina AS c, ROUND(g.elk, 2) AS elk
FROM gerry.gerrySuspects AS psi
INNER JOIN gerry.gerrySuspects AS i ON i.rok = psi.rok AND i.gmina = psi.gmina AND i.indicator = 'Intent'
INNER JOIN gerry.gminy AS g ON g.rok = psi.rok AND g.gmina = psi.gmina
WHERE psi.rok = 2014 AND psi.indicator = 'Psi' AND g.gcUnopp < 5 HAVING rnk <= 200 ORDER BY rnk ASC;