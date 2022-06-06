SELECT g.gmina AS teryt, x.nazwa AS gmina, x.typGminy AS typ, x.typ2010,
    g.lista1, g.lista2, CONCAT(ROUND(g.v1 * 100, 1), '%') AS v1, CONCAT(ROUND(g.v2 * 100, 1), '%') AS v2,
    ROUND(g.w1, 0) AS w1, ROUND(g.w2, 0) AS w2, ROUND(g.gap2, 3) AS gap
FROM gerry.gerryEffGap AS g
INNER JOIN gerry.gminy AS x ON x.rok = g.rok AND x.gmina = g.gmina
WHERE g.rok = 2014 AND g.rank1 = 1 AND g.rank2 = 2 AND g.method = 12 AND g.v1 / g.v2 < 12 AND x.gcUnopp <= 5
ORDER BY g.gap2 DESC LIMIT 25