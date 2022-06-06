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
