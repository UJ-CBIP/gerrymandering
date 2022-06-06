UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT w.rok, w.gmina, w.okreg, w.lista, w.glosow / SUM(w2.glosow) AS pct
    FROM gerry.gerryWybory AS w
    INNER JOIN gerry.gerryWybory AS w2 ON w2.rok = w.rok AND w2.gmina = w.gmina AND w2.okreg = w.okreg AND
        ((w2.glosow > w.glosow) OR (w2.glosow = w.glosow AND w2.lista <= w.lista))
    GROUP BY w.rok, w.gmina, w.okreg, w.lista
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg AND w.lista = x.lista
SET w.plNorm = x.pct;

UPDATE gerry.gerryWybory AS w SET relevant = 1 WHERE w.plNorm > 1 / (2 + w.listOkr);
UPDATE gerry.gerryWybory AS w SET relevant = 1 WHERE listOkr = 1;
UPDATE gerry.gerryWybory AS w SET relevant = 0 WHERE relevant IS NULL;

UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, SUM(relevant) AS c, SUM(glosow * relevant) AS v FROM gerry.gerryWybory GROUP BY rok, gmina, okreg
) AS x ON w.rok = x.rok AND w.gmina = x.gmina AND w.okreg = x.okreg
SET w.listRelev = x.c, w.glosRelev = x.v;

UPDATE gerry.gerry AS g INNER JOIN (
    SELECT g.rok, g.gmina, g.lista, g.gpct,
      SUM(IF(w.mandat = 1, (w.glosow - w.runUp) / 2, w.glosow)) AS w1,
      SUM(IF(w.mandat = 1, (w.glosow - w.runUp) / 2 / w.glosOkr, w.pct)) AS w1n,
      SUM(IF(w.mandat = 1, (w.pct - w.thold) * w.glosOkr, w.glosow)) AS w2,
      SUM(IF(w.mandat = 1, w.pct - w.thold, w.pct)) AS w2n,
      SUM(IF(w.mandat = 1, (w.pct - 2 / (2 + w.listOkr)) * w.glosOkr, w.glosow)) AS w3,
      SUM(IF(w.mandat = 1, w.pct - 2 / (2 + w.listOkr), w.pct)) AS w3n,
      SUM(IF(w.mandat = 1, (w.pct - 2 / (2 + w.listRelev)) * w.glosRelev, w.glosow)) AS w4,
      SUM(w.pct) AS sumpct, g.avgComp AS comp
    FROM gerry.gerryWybory AS w
    INNER JOIN gerry.gerry AS g ON g.rok = w.rok AND g.gmina = w.gmina AND g.lista = w.koalicja
    INNER JOIN gerry.gerry AS g2 ON g2.rok = w.rok AND g2.gmina = w.gmina AND g2.lista != g.lista AND g2.rankGlos <= 2
    INNER JOIN gerry.gerryIntersect AS i ON i.rok = w.rok AND i.gmina = w.gmina AND i.lista1 = w.koalicja AND i.lista2 = g2.lista AND i.okreg = w.okreg
    GROUP BY g.rok, g.gmina, g.lista
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.lista = g.lista
SET g.waste1 = x.w1, g.waste2 = x.w2, g.waste3 = x.w3, g.waste4 = x.w4,
    g.waste1n = x.w1n, g.waste2n = x.w2n, g.waste3n = x.w3n, g.sumpct = x.sumpct;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 1 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste1 AS w1, g2.waste1 AS w2,
    ABS(g1.waste1 - g2.waste1) / (g1.waste1 + g2.waste1) AS gap,
    ABS(g1.waste1 - g2.waste1) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 2 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste2 AS w1, g2.waste2 AS w2,
    ABS(g1.waste2 - g2.waste2) / (g1.waste2 + g2.waste2) AS gap,
    ABS(g1.waste2 - g2.waste2) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 3 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste3 AS w1, g2.waste3 AS w2,
    ABS(g1.waste3 - g2.waste3) / (g1.waste3 + g2.waste3) AS gap,
    ABS(g1.waste3 - g2.waste3) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 4 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste4 AS w1, g2.waste4 AS w2,
    ABS(g1.waste4 - g2.waste4) / (g1.waste4 + g2.waste4) AS gap,
    ABS(g1.waste4 - g2.waste4) / (g1.glos + g2.glos) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 11 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste1n AS w1, g2.waste1n AS w2,
    ABS(g1.waste1n - g2.waste1n) / (g1.waste1n + g2.waste1n) AS gap,
    ABS(g1.waste1n - g2.waste1n) / (g1.sumpct + g2.sumpct) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 12 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste2n AS w1, g2.waste2n AS w2,
    ABS(g1.waste2n - g2.waste2n) / (g1.waste2n + g2.waste2n) AS gap,
    ABS(g1.waste2n - g2.waste2n) / (g1.sumpct + g2.sumpct) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 13 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste3n AS w1, g2.waste3n AS w2,
    ABS(g1.waste3n - g2.waste3n) / (g1.waste3n + g2.waste3n) AS gap,
    ABS(g1.waste3n - g2.waste3n) / (g1.sumpct + g2.sumpct) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 21 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste1n / g1.okr AS w1, g2.waste1n / g2.okr AS w2,
    ABS(g1.waste1n / g1.okr - g2.waste1n / g2.okr) / (g1.waste1n / g1.okr + g2.waste1n / g2.okr) AS gap,
    ABS(g1.waste1n / g1.okr - g2.waste1n / g2.okr) / (g1.sumpct / g1.okr + g2.sumpct / g2.okr) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 22 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste2n / g1.okr AS w1, g2.waste2n / g2.okr AS w2,
    ABS(g1.waste2n / g1.okr - g2.waste2n / g2.okr) / (g1.waste2n / g1.okr + g2.waste2n / g2.okr) AS gap,
    ABS(g1.waste2n / g1.okr - g2.waste2n / g2.okr) / (g1.sumpct / g1.okr + g2.sumpct / g2.okr) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;

REPLACE INTO gerry.gerryEffGap
SELECT g1.rok, g1.gmina, g1.lista AS lista1, g2.lista AS lista2, 23 AS method, g1.rankGlos AS rank1, g2.rankGlos AS rank2,
    g1.v AS v1, g2.v AS v2, g1.s AS s1, g2.s AS s2, g1.waste3n / g1.okr AS w1, g2.waste3n / g2.okr AS w2,
    ABS(g1.waste3n / g1.okr - g2.waste3n / g2.okr) / (g1.waste3n / g1.okr + g2.waste3n / g2.okr) AS gap,
    ABS(g1.waste3n / g1.okr - g2.waste3n / g2.okr) / (g1.sumpct / g1.okr + g2.sumpct / g2.okr) AS gap2
FROM gerry.gerry AS g1 INNER JOIN gerry.gerry AS g2 ON g2.rok = g1.rok AND g2.gmina = g1.gmina AND g2.lista != g1.lista;
