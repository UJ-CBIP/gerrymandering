INSERT INTO gerry.gerryWybory
    (rok, ggmina, okreg, lista, koalicja, glosow, mandat, glosOkr, listOkr, komitet, uuid, rank, effCan, s, pct, cOkr, okrUpraw, ii)
SELECT LEFT(k.akcja, 4) AS rok, LPAD(k.teryt, 6, '0'), w.okreg, w.lista, w.lista AS koalicja, w.glos, w.mandat, w.glosSum, w.n, w.komitet, w.uuid,
    w.rankInter, w.elk, IF(w.rankInter = 1, 1, 0) AS s, w.pctGlos, wk.okrGlobal, f.wartosc AS okrUpraw, w.inkumbent
FROM wynikiAgr AS w
INNER JOIN wynikiKomitety AS wk ON wk.akcja = w.akcja AND wk.jednostka = w.jednostka AND wk.organ = w.organ AND wk.subKod = w.subKod AND
    wk.tura = w.tura AND wk.komitet = w.komitet
INNER JOIN frekwAgr AS f ON f.akcja = w.akcja AND f.organ = 'RDA' AND f.turaPytanie = 1 AND f.poziom = 'OKR' AND
    f.guidAgr = w.jednostka AND f.subAgr = w.okreg AND f.pozycja = '1'
WHERE w.akcja = '20181021/000000/SMD' AND w.organ = 'RDA' AND w.poziom = 'OKR' AND w.system LIKE 'W%';

INSERT IGNORE INTO gerry.gerryWybory
    (rok, gmina, okreg, lista, koalicja, mandat, listOkr, komitet, uuid, rank, elk, effCan, effComp, s, klasa, ii)
SELECT LEFT(k.akcja, 4) AS rok, LPAD(k.teryt, 6, '0'), k.okreg, k.lista, k.lista, 2 AS mandat, 1, k.komitet, k.uuid,
    1 AS rank, 1 AS elk, 1 AS effCan, 0 AS effComp, 1 AS s, k.lista AS klasa, k.inkumbent
FROM wybory.kandydaci AS k
INNER JOIN wybory.wyboryOkregi AS w ON w.akcja = k.akcja AND w.jednostka = k.jednostka AND w.organ = k.organ AND w.subKod = k.subKod AND
    w.okreg = k.okreg AND w.tura = 1
LEFT JOIN wybory.wynikiKomitety AS wk ON wk.akcja = k.akcja AND wk.jednostka = k.jednostka AND wk.organ = k.organ AND wk.subKod = k.subKod AND
    wk.tura = 1 AND wk.komitet = k.komitet
WHERE k.akcja = '20141116/000000/SMD' AND k.organ = 'RDA' AND w.status = 'M';

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, okreg, lista, RANK() OVER (PARTITION BY rok, gmina, okreg ORDER BY glosow DESC) AS rnk FROM gerry.gerryWybory
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND g.okreg = x.okreg AND x.lista = g.lista SET g.rank = x.rnk;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, MAX(glosow) AS zw, MAX(IF(`rank` > 1, glosow, 0)) AS runUp FROM gerry.gerryWybory GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.zw = x.zw, w.runUp = x.runUp;

UPDATE gerry.gerryWybory AS w SET tie = 0;
UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, COUNT(*)-1 AS c FROM gerry.gerryWybory WHERE glosow = zw GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.s = 1 / x.c, w.tie = x.c - 1;

UPDATE gerry.gerryWybory AS w SET tieRunUp = 0;
UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, COUNT(*)-1 AS c FROM gerry.gerryWybory WHERE glosow = runUp GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.tieRunUp = x.c;

UPDATE gerry.gerryWybory SET maxComp = zw, tieComp = tie WHERE s = 0;
UPDATE gerry.gerryWybory SET maxComp = runUp, tieComp = tieRunUp WHERE s = 1;
UPDATE gerry.gerryWybory SET maxComp = zw, tieComp = tie - 1 WHERE s > 0 AND s < 1;
