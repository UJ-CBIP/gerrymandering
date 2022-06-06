UPDATE gerry.gerryWybory AS g SET g.koalicja = g.lista; 
UPDATE gerry.listy AS g SET g.koalicja = NULL;
UPDATE gerry.listy AS g INNER JOIN gerry.gminy AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina SET g.major = IF(g.okr + g.cUnopp > gg.okrGmina / 2, 1, 0);
TRUNCATE TABLE gerry.koalicje;

INSERT INTO gerry.koalicje
SELECT g1.rok, g1.gmina, g1.lista, g2.lista, g1.okr AS c1, g2.okr AS c2, g1.bitmaskUnopp, g2.bitmaskUnopp,
    NOT(g2.minV > g1.maxV OR g1.minV > g2.maxV) AS overlap, IF(g1.bitmask & g2.bitmask = 0, 1, 0) AS exclusive, NULL
FROM gerry.listy AS g1
INNER JOIN gerry.listy AS g2 ON g1.rok = g2.rok AND g1.gmina = g2.gmina AND g1.lista != g2.lista AND g1.okr > g2.okr
WHERE g1.major = 1
HAVING overlap = 1 AND exclusive = 1;

INSERT INTO gerry.koalicje
SELECT g1.rok, g1.gmina, g1.lista, g2.lista, g1.okr AS c1, g2.okr AS c2, g1.bitmaskUnopp, g2.bitmaskUnopp,
    0 AS overlap, IF(g1.bitmask & g2.bitmask = 0, 1, 0) AS exclusive, NULL
FROM gerry.listy AS g1
INNER JOIN gerry.listy AS g2 ON g1.rok = g2.rok AND g1.gmina = g2.gmina AND g1.lista < g2.lista
WHERE g1.major = 0 AND g2.major = 0
HAVING exclusive = 1;
