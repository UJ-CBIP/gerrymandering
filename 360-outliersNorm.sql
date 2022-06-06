INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(LOG(x.cGmina - x.gcUnopp + 1, x.okr + 1)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.q <= g.q
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
SET g.qLess = x.ww;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(LOG(x.cGmina - x.gcUnopp + 1, x.okr + 1)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.q >= g.q
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
SET g.qMore = x.ww;

TRUNCATE TABLE gerry.outliers;

UPDATE gerry.gerry AS g INNER JOIN (
    SELECT rok, gmina, lista,
        CUME_DIST() OVER (PARTITION BY rok, IF(s=1, 1, 0) ORDER BY (uqPos + LOG(cGmina - gcUnopp + 1, okr + 1)) / qLess ASC) AS uqPosNorm,
        CUME_DIST() OVER (PARTITION BY rok, IF(s=0, 1, 0) ORDER BY (uqNeg + LOG(cGmina - gcUnopp + 1, okr + 1)) / qMore ASC) AS uqNegNorm
    FROM gerry.gerry WHERE okr > 0
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
    SET g.uqPosNorm = x.uqPosNorm, g.uqNegNorm = x.uqNegNorm;

UPDATE gerry.gerry AS g SET g.uqNorm = IF(g.uqPos < g.uqNeg, g.uqPosNorm, g.uqNegNorm); 
UPDATE gerry.gerry AS g SET g.uqNorm = LEAST(g.uqPosNorm, g.uqNegNorm);