UPDATE gerry.gerry SET uPos = 0, uNeg = 0;
UPDATE gerry.gerry SET uwPos = 0, uwNeg = 0;
UPDATE gerry.gerry SET uqPos = 0, uqNeg = 0;
UPDATE gerry.gerry SET u = NULL, uw = NULL, uq = NULL;

UPDATE gerry.gerryHypoSV SET up = 0;
UPDATE gerry.gerryHypoSV SET un = 0;
UPDATE gerry.gerryHypoSV SET u = NULL, uNorm = NULL;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.v <= g.v AND x.s >= g.s AND (g.gmina != x.gmina OR g.lista != x.lista)
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND x.shift = 0
SET g.uPos = x.cc, g.uwPos = x.ww;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, 0, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerry AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.v >= g.v AND x.s <= g.s AND (g.gmina != x.gmina OR g.lista != x.lista)
GROUP BY g.rok, g.gmina, g.lista;

UPDATE gerry.gerry AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND x.shift = 0
SET g.uNeg = x.cc, g.uwNeg = x.ww;

TRUNCATE TABLE gerry.outliers;

UPDATE gerry.gerry AS g SET g.u = LEAST(g.uPos, g.uNeg);
UPDATE gerry.gerry AS g SET g.uw = LEAST(g.uwPos, g.uwNeg);

UPDATE gerry.gerryHypoSV SET up = NULL, un = NULL, u = NULL WHERE normV = 0 OR normV = 1;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, g.shift, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerryHypoSV AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.normV <= g.normV AND x.s >= g.s AND (g.gmina != x.gmina OR g.lista != x.lista) AND x.normV > 0
WHERE g.normV > 0
GROUP BY g.rok, g.gmina, g.lista, g.shift;

UPDATE gerry.gerryHypoSV AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND g.shift = x.shift
SET g.up = x.ww;

TRUNCATE TABLE gerry.outliers;

INSERT INTO gerry.outliers
SELECT g.rok, g.gmina, g.lista, g.shift, COUNT(*) AS cc, SUM(POWER(x.okr / x.cGmina, 2)) AS ww FROM gerry.gerryHypoSV AS g
INNER JOIN gerry.gerry AS x ON g.rok = x.rok AND x.normV >= g.normV AND x.s <= g.s AND (g.gmina != x.gmina OR g.lista != x.lista) AND x.normV > 0
WHERE g.normV > 0
GROUP BY g.rok, g.gmina, g.lista, g.shift;

UPDATE gerry.gerryHypoSV AS g INNER JOIN gerry.outliers AS x ON
    g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista AND g.shift = x.shift
SET g.un = x.ww;

TRUNCATE TABLE gerry.outliers;

UPDATE gerry.gerryHypoSV AS g SET g.u = LEAST(g.up, g.un) WHERE normV > 0 AND normV < 1;
UPDATE gerry.gerryHypoSV AS g SET g.uNorm = LEAST(g.up / g.normV, g.un / (1 - g.normV)) WHERE normV > 0 AND normV < 1;
UPDATE gerry.gerryHypoSV SET up = 0, u = 0, uNorm = 0 WHERE normV = 0 AND s > 0;
