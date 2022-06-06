INSERT INTO gerry.wbp
SELECT '2014', LPAD(t.teryt, 6, '0'), w.lista, w.obwod, obw.adres, obw.teren, f.upraw AS pop, f.frekw AS turnout,
    f.upraw / SUM(f.upraw) OVER (PARTITION BY t.teryt, w.lista) AS normPop,
    f.frekw / SUM(f.frekw) OVER (PARTITION BY t.teryt, w.lista) AS normTurnout,
    w.glos, w.glos / SUM(w.glos + w.przeciw) OVER (PARTITION BY t.teryt, w.obwod) AS v,
    w.glos / SUM(w.glos) OVER (PARTITION BY t.teryt, w.lista) AS prob,
    RANK() OVER (PARTITION BY t.teryt, w.obwod ORDER BY w.glos DESC) AS rankObw,
    NULL AS rankV, ROW_NUMBER() OVER (PARTITION BY t.teryt, w.lista ORDER BY w.glos DESC) AS rankShare,
    NULL AS lorenzPop, NULL AS lorenzShare, NULL AS topHalf, NULL AS cluster
FROM wybory.wynikiObw AS w
INNER JOIN wybory.obwody AS obw ON obw.akcja = w.akcja AND obw.jst = w.gmina AND obw.obwod = w.obwod
INNER JOIN wybory.wyboryTury AS t ON t.akcja = w.akcja AND t.jednostka = w.jednostka AND t.organ = w.organ AND t.subKod = w.subKod AND t.tura = w.tura
INNER JOIN wybory.frekwAgrWide AS f ON f.akcja = w.akcja AND f.organ = w.organ AND f.turaPytanie = 1 AND f.poziom = 'OBW' AND f.guidAgr = w.gmina AND f.subAgr = w.obwod
WHERE w.akcja = '20141116/000000/SMD' AND w.organ = 'WBP' AND w.tura = 1 AND obw.typ = 'P';

UPDATE gerry.wbp INNER JOIN (
    SELECT rok, gmina, lista, obwod, ROW_NUMBER() OVER (PARTITION BY rok, gmina, lista ORDER BY v DESC) AS r FROM gerry.wbp
) AS x ON wbp.rok = x.rok AND wbp.gmina = x.gmina AND wbp.lista = x.lista AND wbp.obwod = x.obwod SET wbp.rankV = x.r;

REPLACE INTO gerry.polarWBP (rok, gmina, lista, inkumbent, pretendent, winner, rnk)
SELECT rok, gmina, lista, IF(tag = 'i', 1, 0) AS inkumbent, IF(tag = 'p', 1, 0) AS pretendent,
    CASE tag2 WHEN 'u' THEN 0 WHEN '1' THEN 1 WHEN '2' THEN 2 END AS winner, rankWojt
FROM gerry.gerry WHERE tag IS NOT NULL;

UPDATE gerry.polarWBP AS p INNER JOIN (
    SELECT w1.rok, w1.gmina, w1.lista, SUM(POWER(w1.share, 2) * w2.share * ABS(w1.v - w2.v)) AS er,
        COUNT(DISTINCT w1.obwod) AS cObw
    FROM gerry.wbp AS w1
    INNER JOIN gerry.wbp AS w2 ON w2.rok = w1.rok AND w2.gmina = w1.gmina AND w2.lista = w1.lista
    GROUP BY w1.rok, w1.gmina, w1.lista
) AS x ON x.rok = p.rok AND x.gmina = p.gmina AND x.lista = p.lista SET p.esteban = x.er, p.cObw = x.cObw;
