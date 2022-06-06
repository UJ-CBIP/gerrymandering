INSERT INTO gerry.listy (
    rok, gmina, lista, okr, pct, mandatow, mandatowNT, glos, glosMax, v, s, cUnopp,
    tag, tag2, rankWojt, bitmask, bitmaskUnopp, ecdfV, minV, maxV, inkumbent, pretendent, sukcesor, pctWojt
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
    IFNULL(w.inkumbent, 0) AS inkumbent, IFNULL(w.pretendent, 0) AS pretendent, IFNULL(w.sukcesor, 0) AS sukcesor,
	w.pct1tura
FROM gerry.gerryWybory AS g
LEFT JOIN wsmip.samWojt AS w ON w.rok = g.rok AND w.teryt = g.gmina AND w.lista = g.lista
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.listy SET s = (mandatow - cUnopp) / okr;

UPDATE gerry.listy AS g INNER JOIN (
    SELECT rok, gmina, lista, RANK() OVER (PARTITION BY rok, gmina ORDER BY glos DESC) AS rnk FROM gerry.listy
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.lista = g.lista SET g.rankGlos = x.rnk;