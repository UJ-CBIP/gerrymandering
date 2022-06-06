UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT g.rok, g.gmina, g.okreg, g.lista, POWER(g.glosOkr - g.glosow, 2) / SUM(POWER(gg.glosow, 2)) AS elk
    FROM gerry.gerryWybory AS g
    INNER JOIN gerry.gerryWybory AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina AND gg.okreg = g.okreg AND gg.lista != g.lista
    GROUP BY g.rok, g.gmina, g.okreg, g.lista
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.okreg = g.okreg AND x.lista = g.lista
SET g.elk = x.elk, g.effComp = x.elk;

UPDATE gerry.gerry AS g INNER JOIN (
	SELECT rok, gmina, koalicja AS lista, MAX(listOkr) - 1 AS maxComp, AVG(listOkr) - 1 AS avgComp,
	    AVG(effComp) AS avgElk, COUNT(*) / SUM(1 / effComp) AS harElk
	FROM gerry.gerryWybory GROUP BY rok, gmina, koalicja
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
SET g.maxComp = x.maxComp, g.avgComp = x.avgComp, g.avgElk = x.avgElk;

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, koalicja, AVG(pct) AS meanPct FROM gerry.gerryWybory WHERE listOkr > 1 GROUP BY rok, gmina, koalicja
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.koalicja = g.koalicja
SET g.meanPct = x.meanPct;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT w.rok, w.gmina, w.lista, w.okreg, ROW_NUMBER() OVER (PARTITION BY rok, gmina, koalicja ORDER BY pct DESC) AS rnk, w.pct FROM gerry.gerryWybory AS w
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.lista = x.lista AND w.okreg = x.okreg
SET w.dRank = x.rnk;

UPDATE gerry.gerryWybory AS g INNER JOIN (
    SELECT rok, gmina, okreg, GROUP_CONCAT(koalicja) AS klasa FROM gerry.gerryWybory GROUP BY rok, gmina, okreg
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.okreg = x.okreg SET g.klasa = x.klasa;
