INSERT INTO gerry.gerryMono
SELECT i.rok, i.gmina, i.lista1, i.lista2, g1.okr / g1.cGmina AS c1, g2.okr / g2.cGmina AS c2, COUNT(*) AS cInter,
    BIT_COUNT((g1.bitmask | g2.bitmask) & IF(i.rok = 9999, (1 << 63) - 1, (1 << 31) - 1)) AS cSum,
    1 / (g1.rankGlos + g2.rankGlos - 1) AS hw, g1.v - g2.v AS deltaV, g1.s - g2.s AS deltaS,
    IF(SIGN(g1.v - g2.v) = -SIGN(g1.s - g2.s), 0, 1) AS mono, NULL AS eta
FROM gerry.gerryIntersect AS i
INNER JOIN gerry.gerry AS g1 ON g1.rok = i.rok AND g1.gmina = i.gmina AND g1.lista = i.lista1
INNER JOIN gerry.gerry AS g2 ON g2.rok = i.rok AND g2.gmina = i.gmina AND g2.lista = i.lista2
GROUP BY i.rok, i.gmina, i.lista1, i.lista2;

UPDATE gerry.gerryMono SET eta = (ABS(deltaV) + ABS(deltaS)) * (1 - mono) * hw;

DROP VIEW IF EXISTS gerry.gerryMonoGminy;

CREATE VIEW gerry.gerryMonoGminy AS
SELECT rok, gmina, SUM(eta) / SUM(hw) AS eta, SUM(IF(eta > 0, 1, 0)) AS cPairs FROM gerry.gerryMono
WHERE c1 >= 0.5 AND c2 >= 0.5 AND cInter / cSum >= 0.5 AND deltaV >= 0
GROUP BY rok, gmina;

SELECT m.gmina, g.nazwa, ROUND(m.eta, 4), m.cPairs, g.typ, g.komGmina, g.okrGmina, g.glosGmina FROM gerry.gerryMonoGminy AS m
INNER JOIN gerry.gminy AS g ON g.rok = m.rok AND g.gmina = m.gmina
WHERE g.rok = 2014 ORDER BY eta DESC LIMIT 20;
