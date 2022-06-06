UPDATE gerry.gminy AS g INNER JOIN (
    SELECT rok, gmina, AVG(IF(inkumbent = 1, lista, NULL)) AS gwi, AVG(IF(rankWojt = 1, lista, NULL)) AS gww,
		AVG(IF(pretendent = 1, lista, NULL)) AS gwp, AVG(IF(rankWojt = 2, lista, NULL)) AS gwr
    FROM gerry.gerry GROUP BY rok, gmina
) AS x ON g.rok = x.rok AND g.gmina = x.gmina SET g.lstIncumbent = x.gwi, g.lstWinner = x.gww, g.lstChallenger = x.gwp, g.lstRunUp = x.gwr;

UPDATE gerry.gminy AS g INNER JOIN (
    SELECT LEFT(akcja, 4) AS rok, MAX(lista) AS maxlst FROM wybory.komitety AS k WHERE k.akcja LIKE '%/SMD' GROUP BY rok
) AS x ON g.rok = x.rok SET g.partisan = IFNULL(IF(g.lstIncumbent <= x.maxlst, 1, 0), 0);

UPDATE gerry.gminy AS g INNER JOIN (
    SELECT rok, gmina, 1 / SUM(gpct * gpct) AS elk FROM gerry.gerry GROUP BY rok, gmina
) AS x ON g.rok = x.rok AND g.gmina = x.gmina SET g.elk = x.elk;
