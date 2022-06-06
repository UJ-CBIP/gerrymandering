INSERT INTO gerry.gerryIntersect
SELECT rok, gmina, koalicja, 0, okreg FROM gerry.gerryWybory WHERE listOkr > 1;

INSERT INTO gerry.gerryIntersect
SELECT w1.rok, w1.gmina, w1.koalicja, w2.koalicja, w1.okreg FROM gerry.gerryWybory AS w1
INNER JOIN gerry.gerryWybory AS w2 ON w2.rok = w1.rok AND w2.gmina = w1.gmina AND w2.okreg = w1.okreg AND w2.koalicja != w1.koalicja;

INSERT INTO gerry.gerrySwing
SELECT i.rok, i.gmina, i.lista1, i.lista2, 'uniform',
    ROW_NUMBER() OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2 ORDER BY w.reqSwing ASC) AS man,
    COUNT(*) OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2) AS c, w.reqSwing AS swing, NULL AS v, NULL AS s
FROM gerry.gerryIntersect AS i
INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
ORDER BY rok, gmina, lista1, lista2, man;

UPDATE gerry.gerrySwing AS g INNER JOIN (
    SELECT i.rok, i.gmina, i.lista1, i.lista2, s.method, s.man,
        SUM(GREATEST(LEAST(w.pct + s.swing, 1), 0) * w.glosOkr) / SUM(w.glosOkr) AS vv
    FROM gerry.gerryIntersect AS i
    INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
    INNER JOIN gerry.gerrySwing AS s ON s.rok = i.rok AND s.gmina = i.gmina AND s.lista1 = i.lista1 AND s.lista2 = i.lista2 AND
        s.method = 'uniform'
    GROUP BY i.rok, i.gmina, i.lista1, i.lista2, s.method, s.man
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista1 = x.lista1 AND g.lista2 = x.lista2 AND g.method = x.method AND g.man = x.man
SET g.v = x.vv;

# UPDATE gerry.gerrySwing SET method = 'probit0' WHERE method = 'probit';
# DELETE FROM gerry.gerrySwing WHERE method IN ('quantile', 'probit', 'logit');

INSERT INTO gerry.gerrySwing
SELECT i.rok, i.gmina, i.lista1, i.lista2, 'quantile',
    ROW_NUMBER() OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2 ORDER BY w.reqSwingQ ASC) AS man,
    COUNT(*) OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2) AS c, w.reqSwingQ AS swing, NULL AS v, NULL AS s
FROM gerry.gerryIntersect AS i
INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
ORDER BY rok, gmina, lista1, lista2, man;

INSERT INTO gerry.gerrySwing
SELECT i.rok, i.gmina, i.lista1, i.lista2, 'probit',
    ROW_NUMBER() OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2 ORDER BY w.reqSwingP ASC) AS man,
    COUNT(*) OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2) AS c, w.reqSwingP AS swing, NULL AS v, NULL AS s
FROM gerry.gerryIntersect AS i
INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
ORDER BY rok, gmina, lista1, lista2, man;

INSERT INTO gerry.gerrySwing
SELECT i.rok, i.gmina, i.lista1, i.lista2, 'logit',
    ROW_NUMBER() OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2 ORDER BY w.reqSwingL ASC) AS man,
    COUNT(*) OVER (PARTITION BY i.rok, i.gmina, i.lista1, i.lista2) AS c, w.reqSwingL AS swing, NULL AS v, NULL AS s
FROM gerry.gerryIntersect AS i
INNER JOIN gerry.gerryWybory AS w ON w.rok = i.rok AND w.gmina = i.gmina AND w.koalicja = i.lista1 AND w.okreg = i.okreg
ORDER BY rok, gmina, lista1, lista2, man;
