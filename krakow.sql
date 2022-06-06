# INSERT INTO gerry.krakowObwodyW14
# SELECT w.subAgr AS obwod, w.lista, w.glos, w.komitet, f.upraw, f.frekw, obw.adres FROM wybory.wynikiListy AS w
# INNER JOIN wybory.frekwAgrWide AS f ON f.akcja = w.akcja AND f.organ = w.organ AND f.turaPytanie = 1 AND f.poziom = 'OBW' AND
#     f.guidAgr = w.guidAgr AND f.subAgr = w.subAgr
# INNER JOIN wybory.obwody AS obw ON obw.akcja = w.akcja AND obw.jst = w.guidAgr AND obw.obwod = w.subAgr
# WHERE w.akcja = '20141116/000000/SMD' AND w.jednostka = (SELECT guid FROM wybory.jst WHERE teryt = 126101) AND
#     w.organ = 'RDA' AND w.poziom = 'OBW';
    
REPLACE INTO gerry.gerryWybory (rok, gmina, okreg, lista, koalicja, glosow, mandat, glosOkr, okrUpraw, komitet)
SELECT 9999 AS rok, k.id AS gmina, k.okreg, w.lista, w.lista AS koalicja, SUM(w.glos) AS glosow,
    0 AS mandat, SUM(k.glos) AS glosOkr, SUM(k.upraw) AS okrUpraw,
    CASE w.lista WHEN 3 THEN 'PiS' WHEN 4 THEN 'PO' WHEN 13 THEN 'ERL' WHEN 14 THEN 'Korwin' WHEN 15 THEN 'Ptaszkiewicz'
        WHEN 16 THEN 'Obywatele' WHEN 17 THEN 'Majchrowski' WHEN 18 THEN 'KPI' WHEN 19 THEN 'Gibala' WHEN 20 THEN 'Libert'
    ELSE w.komitet END AS komitet
FROM gerry.krakow AS k INNER JOIN gerry.krakowObwodyW14 AS w ON k.obwod = w.obwod
GROUP BY k.id, k.okreg, w.lista ORDER BY id, lista, okreg;

UPDATE gerry.gerryWybory SET pct = glosow / glosOkr WHERE rok = 9999;

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, okreg, lista, RANK() OVER (PARTITION BY rok, gmina, okreg ORDER BY glosow DESC) AS rnk FROM gerry.gerryWybory
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND g.okreg = x.okreg AND x.lista = g.lista SET g.rank = x.rnk WHERE g.rok = 9999;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, MAX(glosow) AS zw, MAX(IF(`rank` > 1, glosow, 0)) AS runUp FROM gerry.gerryWybory GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.zw = x.zw, w.runUp = x.runUp WHERE w.rok = 9999;

UPDATE gerry.gerryWybory AS w SET tie = 0 WHERE w.rok = 9999;
UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, COUNT(*) AS c FROM gerry.gerryWybory WHERE glosow = zw GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.s = IF(w.glosow = w.zw, 1 / x.c, 0), w.tie = x.c - 1 WHERE w.rok = 9999;

UPDATE gerry.gerryWybory AS w SET tieRunUp = 0 WHERE w.rok = 9999;
UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, COUNT(*) AS c FROM gerry.gerryWybory WHERE glosow = runUp GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.tieRunUp = x.c - 1 WHERE w.rok = 9999;

UPDATE gerry.gerryWybory SET mandat = 1 WHERE rok = 9999 AND s = 1;

UPDATE gerry.gerryWybory SET maxComp = zw, tieComp = tie WHERE s = 0 AND rok = 9999;
UPDATE gerry.gerryWybory SET maxComp = runUp, tieComp = tieRunUp WHERE s = 1 AND rok = 9999;
UPDATE gerry.gerryWybory SET maxComp = zw, tieComp = tie - 1 WHERE s > 0 AND s < 1 AND rok = 9999;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, lista, COUNT(*) AS listOkr, 1 / SUM(POWER(pct, 2)) AS effCan
    FROM gerry.gerryWybory WHERE rok = 9999 GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.listOkr = x.listOkr, w.effCan = x.effCan WHERE w.rok = 9999;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, COUNT(DISTINCT okreg) AS cOkr,
        COUNT(DISTINCT IF(listOkr > 1, okreg, NULL)) AS cOkrWyb
    FROM gerry.gerryWybory WHERE rok = 9999 GROUP BY rok, gmina
) AS x ON w.rok = x.rok AND w.gmina = x.gmina
SET w.cOkr = x.cOkr, w.cOkrWyb = x.cOkrWyb WHERE w.rok = 9999;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT w.rok, w.gmina, w.okreg, w.lista, w.pct, cdf.x1 + (w.pct - cdf.y1) / (cdf.y2 - cdf.y1) * (cdf.x2 - cdf.x1) AS cdf,
        cdf.x1, cdf.x2, cdf.y1, cdf.y2 FROM gerry.gerryWybory AS w
    STRAIGHT_JOIN gerry.ecdfV_inv AS cdf ON cdf.rok = '2014' AND cdf.n = w.listOkr AND w.pct BETWEEN cdf.y1 AND cdf.y2
    WHERE w.rok = 9999
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg AND w.lista = x.lista
SET w.ecdfV = x.cdf;

REPLACE INTO gerry.listy (
    rok, gmina, lista, okr, pct, mandatow, mandatowNT, glos, glosMax, v, s, cUnopp,
    tag, tag2, rankWojt, bitmask, bitmaskUnopp, ecdfV, minV, maxV, inkumbent, pretendent
    )
SELECT g.rok, g.gmina, g.lista, SUM(IF(g.listOkr > 1, 1, 0)) AS okr,
    SUM(g.glosow) / SUM(g.glosOkr) AS pct, SUM(g.s) AS m, SUM(SIGN(g.mandat)) AS mnt,
    SUM(g.glosow) AS glos, SUM(g.glosOkr) AS glosMax,
    SUM(g.glosow) / SUM(g.glosOkr) AS v, NULL AS s,
    SUM(IF(g.mandat = 2, 1, 0)) AS cUnopp,
    IF(w.lista IS NULL, NULL, IF(w.inkumbent = 1, 'i', IF(w.pretendent = 1, 'p', 'w'))) AS tag,
    IF(w.lista IS NULL, NULL, IF(w.n = 1, 'u', IF(w.wybor > 0, w.wybor, IF(w.pct2tura > 0, 'r', NULL)))) AS tag2,
    w.rank AS rankWojt,
    SUM(IF(g.listOkr > 1, 1 << (g.okreg - 1), 0)) + IF(w.lista IS NOT NULL, 1 << 31, 0) AS bitmask,
    SUM(1 << (g.okreg - 1)) + IF(w.lista IS NOT NULL, 1 << 31, 0) AS bitmaskUnopp,
    AVG(IF(g.listOkr > 1, g.ecdfV, NULL)) AS ecdfV,
    MIN(IF(g.listOkr > 1, g.ecdfV, 0)) AS minV, MAX(IF(g.listOkr > 1, g.ecdfV, 0)) AS maxV,
    IFNULL(w.inkumbent, 0) AS inkumbent, IFNULL(w.pretendent, 0) AS pretendent
    # IFNULL(w.sukcesor, 0) AS sukcesor,     w.pct1tura
FROM gerry.gerryWybory AS g
LEFT JOIN wsmip.samWojt AS w ON w.rok = g.rok AND w.teryt = g.gmina AND w.lista = g.lista
WHERE g.rok = 9999
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.listy AS g SET g.koalicja = g.lista WHERE rok = 9999;
UPDATE gerry.listy SET s = (mandatow - cUnopp) / okr WHERE rok = 9999;

UPDATE gerry.listy AS g INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY glos DESC) AS rnk FROM gerry.listy
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.lista = g.lista SET g.rankGlos = x.rnk WHERE g.rok = 9999;
 
REPLACE INTO gerry.gminy
SELECT w.rok, w.gmina, 'Kraków', 0 AS typ, 'xx',
    COUNT(DISTINCT w.koalicja) AS komGmina, COUNT(DISTINCT w.okreg) AS okrGmina, SUM(w.glosow) AS glosGmina,
    SUM(IF(w.listOkr = 1, 1, 0)) AS gcUnopp, NULL AS gvUnopp,
    NULL AS ii, NULL AS pi, NULL AS ai, NULL AS iiPack,
    NULL, NULL, NULL, NULL, NULL AS elk, NULL AS compet, '' AS partisan, NULL AS partiaWladzy,
    NULL AS effRDA
FROM gerry.gerryWybory AS w
WHERE w.rok = 9999 GROUP BY w.rok, w.gmina;

REPLACE INTO gerry.gerry (
    rok, gmina, lista, nazwa, typGminy, typ2010, okr, pct, mandatow, manNT, glos, glosMax, v, s, sNT, cGmina, vGmina, gpct, q,
    cUnopp, vUnopp, gcUnopp, gvUnopp, tag, tag2, rankWojt, bitmask, bitmaskUnopp, members, inkumbent, pretendent,
    cSize, idCore, cCore, vCore, sCore
    )
SELECT g.rok, g.gmina, IFNULL(g.koalicja, g.lista) AS lista, gg.nazwa, gg.typGminy, gg.typ2010,
    SUM(g.okr) AS okr, SUM(g.glos) / SUM(g.glosMax) AS pct, SUM(g.mandatow) AS mandatow, SUM(g.mandatowNT) AS manNT,
    SUM(g.glos) AS glos, SUM(g.glosMax) AS glosMax,
    SUM(g.glos) / SUM(g.glosMax) AS v, SUM(g.mandatow - g.cUnopp) / SUM(g.okr) AS s, SUM(g.mandatowNT - g.cUnopp) / SUM(g.okr) AS sNT,
    gg.okrGmina AS okrGmina, gg.glosGmina AS glosGmina, SUM(g.glos) / gg.glosGmina AS gpct, NULL AS q,
    SUM(g.cUnopp) AS cUnopp, SUM(NULL) AS glosUnopp, gg.gcUnopp, NULL AS gvUnopp,
    GROUP_CONCAT(g.tag) AS tag, GROUP_CONCAT(g.tag2) AS tag2, SUM(g.rankWojt) AS rankWojt,
    SUM(g.bitmask) AS bitmask, SUM(g.bitmaskUnopp) AS bitmaskUnopp, GROUP_CONCAT(g.lista) AS members,
    SUM(g.inkumbent) AS inkumbent, SUM(g.pretendent) AS pretendent, COUNT(*) AS cSize,
    IFNULL(g.koalicja, g.lista) AS idCore, SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.okr, 0)) AS cCore,
    SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.glos, 0)) AS vCore,
    SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.mandatow, 0)) AS sCore
FROM gerry.listy AS g INNER JOIN gerry.gminy AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina
WHERE g.rok = 9999 GROUP BY g.rok, g.gmina, IFNULL(g.koalicja, g.lista);

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT g.rok, g.gmina, g.okreg, g.lista, POWER(g.glosOkr - g.glosow, 2) / SUM(POWER(gg.glosow, 2)) AS elk
    FROM gerry.gerryWybory AS g
    INNER JOIN gerry.gerryWybory AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina AND gg.okreg = g.okreg AND gg.lista != g.lista
    WHERE g.rok = 9999
    GROUP BY g.rok, g.gmina, g.okreg, g.lista
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.okreg = g.okreg AND x.lista = g.lista
SET g.elk = x.elk, g.effComp = x.elk;

UPDATE gerry.gerry AS g INNER JOIN (
    SELECT rok, gmina, koalicja AS lista, MAX(listOkr) - 1 AS maxComp, AVG(listOkr) - 1 AS avgComp,
        AVG(effComp) AS avgElk, COUNT(*) / SUM(1 / effComp) AS harElk
    FROM gerry.gerryWybory WHERE rok = 9999 GROUP BY rok, gmina, koalicja
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
SET g.maxComp = x.maxComp, g.avgComp = x.avgComp, g.avgElk = x.avgElk;

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, koalicja, AVG(pct) AS meanPct FROM gerry.gerryWybory WHERE listOkr > 1 AND rok = 9999 GROUP BY rok, gmina, koalicja
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.koalicja = g.koalicja
SET g.meanPct = x.meanPct;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT w.rok, w.gmina, w.lista, w.okreg, RANK() OVER (PARTITION BY rok, gmina, koalicja ORDER BY pct DESC) AS rnk, w.pct FROM gerry.gerryWybory AS w
    WHERE rok = 9999
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.lista = x.lista AND w.okreg = x.okreg
SET w.dRank = x.rnk;

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, okreg, GROUP_CONCAT(koalicja) AS klasa FROM gerry.gerryWybory WHERE rok = 9999 GROUP BY rok, gmina, okreg
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.okreg = x.okreg SET g.klasa = x.klasa;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY glos DESC) AS rnk FROM gerry.gerry
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankGlos = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY mandatow DESC) AS rnk FROM gerry.gerry
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankMan = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY okr DESC) AS rnk FROM gerry.gerry
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankOkr = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY mandatow + cUnopp DESC) AS rnk FROM gerry.gerry
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankManU = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY okr + cUnopp DESC) AS rnk FROM gerry.gerry
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankOkrU = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY v DESC) AS rnk FROM gerry.gerry WHERE okr > 0
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankV = x.rnk;

UPDATE gerry.gerry AS w INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY s DESC, v DESC) AS rnk FROM gerry.gerry WHERE okr > 0
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.lista = w.lista
SET w.rankS = x.rnk;

UPDATE gerry.gminy AS g INNER JOIN (
    SELECT rok, gmina, 1 / SUM(gpct * gpct) AS elk FROM gerry.gerry GROUP BY rok, gmina
) AS x ON g.rok = x.rok AND g.gmina = x.gmina SET g.elk = x.elk; 

REPLACE INTO gerry.gerryHypoWybory
SELECT w.rok, w.gmina, w.okreg, w.koalicja, w.glosow AS v0, seq.i - 10 AS shift, GREATEST(0, w.glosow + seq.i - 10) AS vShift, NULL AS s,
    IF(glosow = zw, runUp, zw) AS tc, IF(glosow = zw, GREATEST(tie - 1, 0), tieRunUp) AS tie, w.glosOkr - w.glosow + GREATEST(0, w.glosow + seq.i - 10) AS glosOkr
FROM gerry.gerryWybory AS w INNER JOIN common._seq AS seq ON seq.i BETWEEN 0 AND 20
WHERE w.listOkr > 1 AND w.rok = 9999;

UPDATE gerry.gerryHypoWybory SET s = IF(vShift > tc, 1, IF(vShift = tc, 1 / (tie + 1), 0)) WHERE rok = 9999;

REPLACE INTO gerry.gerryHypoSV
SELECT w.rok, w.gmina, w.lista, w.shift, NULL AS w, SUM(w.vShift) / SUM(w.glosOkr) AS v, NULL AS q, SUM(w.s) AS man, COUNT(*) AS okr,
    SUM(w.s) / COUNT(*) AS s, g.avgThold, NULL AS normV, NULL AS pLess, NULL AS pMore, NULL AS pExact, NULL AS pValue,
    NULL AS npMeanS, NULL AS npDevS, NULL AS npDistS, NULL AS phi,
    NULL AS up, NULL AS un, NULL AS u, NULL AS uNorm
FROM gerry.gerryHypoWybory AS w INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.lista
WHERE w.rok = 9999 GROUP BY w.rok, w.gmina, w.lista, w.shift;

UPDATE gerry.gerryHypoSV SET w = EXP(-2*POWER(shift, 2)/POWER(5, 2)) WHERE rok = 9999;

UPDATE gerry.gerryWybory AS w
INNER JOIN gerry.gammaFit AS g ON g.rok = 2014 AND g.n = w.listOkr
SET w.k = g.k, w.theta = g.theta, w.eAlpha = g.k * g.theta WHERE w.rok = 9999;

UPDATE gerry.gerry SET uPos = 0, uNeg = 0 WHERE rok = 9999;
UPDATE gerry.gerry SET uwPos = 0, uwNeg = 0 WHERE rok = 9999;
UPDATE gerry.gerry SET uqPos = 0, uqNeg = 0 WHERE rok = 9999;
UPDATE gerry.gerry SET u = NULL, uw = NULL, uq = NULL WHERE rok = 9999;

UPDATE gerry.gerryHypoSV SET up = 0 WHERE rok = 9999;
UPDATE gerry.gerryHypoSV SET un = 0 WHERE rok = 9999;
UPDATE gerry.gerryHypoSV SET u = NULL, uNorm = NULL WHERE rok = 9999;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON x.rok = 2014 AND x.v <= g.v AND x.s >= g.s
WHERE g.rok = 9999 GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND x.shift = 0
SET g.uPos = x.cc, g.uwPos = x.ww;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON x.rok = 2014 AND x.v >= g.v AND x.s <= g.s
WHERE g.rok = 9999 GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND x.shift = 0
SET g.uNeg = x.cc, g.uwNeg = x.ww;

TRUNCATE TABLE gerry.outliers;

UPDATE gerry.gerry AS g SET g.u = LEAST(g.uPos, g.uNeg) WHERE rok = 9999;
UPDATE gerry.gerry AS g SET g.uw = LEAST(g.uwPos, g.uwNeg) WHERE rok = 9999;

UPDATE gerry.gerryHypoSV SET up = NULL, un = NULL, u = NULL WHERE normV = 0 OR normV = 1 AND rok = 9999;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, g.shift, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerryHypoSV AS g
INNER JOIN gerry.gerry AS x ON x.rok = 2014 AND x.normV <= g.normV AND x.s >= g.s AND x.normV > 0
WHERE g.rok = 9999 AND g.normV > 0 GROUP BY g.rok, g.gmina, g.lista, g.shift;

UPDATE gerry.gerryHypoSV AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND g.shift = x.shift
SET g.up = x.ww;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, g.shift, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerryHypoSV AS g
INNER JOIN gerry.gerry AS x ON x.rok = 2014 AND x.normV >= g.normV AND x.s <= g.s AND x.normV > 0
WHERE g.rok = 9999 AND g.normV > 0 GROUP BY g.rok, g.gmina, g.lista, g.shift;

UPDATE gerry.gerryHypoSV AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND g.shift = x.shift
SET g.un = x.ww;

TRUNCATE TABLE gerry.outliers;

UPDATE gerry.gerryHypoSV AS g SET g.u = LEAST(g.up, g.un) WHERE rok = 9999 AND normV > 0 AND normV < 1;
UPDATE gerry.gerryHypoSV AS g SET g.uNorm = LEAST(g.up / g.normV, g.un / (1 - g.normV)) WHERE rok = 9999 AND normV > 0 AND normV < 1;
UPDATE gerry.gerryHypoSV SET up = 0, u = 0 WHERE rok = 9999 AND normV = 0 AND s > 0;

INSERT INTO gerry.gerryIntersect
SELECT rok, gmina, koalicja, 0, okreg FROM gerry.gerryWybory WHERE listOkr > 1 AND rok = 9999;

INSERT INTO gerry.gerryIntersect
SELECT w1.rok, w1.gmina, w1.koalicja, w2.koalicja, w1.okreg FROM gerry.gerryWybory AS w1
INNER JOIN gerry.gerryWybory AS w2 ON w2.rok = w1.rok AND w2.gmina = w1.gmina AND w2.okreg = w1.okreg AND w2.koalicja != w1.koalicja
WHERE w1.rok = 9999;
