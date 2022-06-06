UPDATE gerry.gerry AS g INNER JOIN (
    SELECT g.rok, g.gmina, g.lista, g.gpct,
      SUM(IF(w.mandat = 1, (w.glosow - w.runUp) / 2, w.glosow)) AS w1,
      SUM(IF(w.mandat = 1, (w.pct - w.thold) * w.glosOkr, w.glosow)) AS w2,
      SUM(IF(w.mandat = 1, (w.pct - 2 / (2 + w.listOkr)) * w.glosOkr, w.glosow)) AS w3,
      g.avgComp AS comp
    FROM gerry.gerryWybory AS w
    INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
    INNER JOIN gerry.gerry AS g2 ON g2.rok = w.rok AND g2.gmina = w.gmina AND g2.lista != g.lista AND g2.rankGlos <= 2
    INNER JOIN gerry.gerryIntersect AS i ON i.rok = w.rok AND i.gmina = w.gmina AND i.lista1 = w.koalicja AND i.lista2 = g2.lista AND i.okreg = w.okreg
    GROUP BY g.rok, g.gmina, g.lista
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.lista = g.lista
SET g.waste1 = x.w1, g.waste2 = x.w2, g.waste3 = x.w3;

INSERT INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 1 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste1 AS w1, g2.waste1 AS w2,
    ABS(g1.waste1 - g2.waste1) / (g1.waste1 + g2.waste1) AS gap,
    ABS(g1.waste1 - g2.waste1) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

INSERT INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 2 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste2 AS w1, g2.waste2 AS w2,
    ABS(g1.waste2 - g2.waste2) / (g1.waste2 + g2.waste2) AS gap,
    ABS(g1.waste2 - g2.waste2) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

INSERT INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 3 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste3 AS w1, g2.waste3 AS w2,
    ABS(g1.waste3 - g2.waste3) / (g1.waste3 + g2.waste3) AS gap,
    ABS(g1.waste3 - g2.waste3) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;