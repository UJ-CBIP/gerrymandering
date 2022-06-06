SELECT x.gmina, g.nazwa, CONCAT(ROUND((SUM(c) - COUNT(c)) / g.okrGmina * 100, 0), '%') AS I, COUNT(c), g.typ, g.komGmina, g.okrGmina, g.glosGmina, g.typ2010
FROM (
    SELECT rok, gmina, okreg, COUNT(*) AS c FROM gerry.gerryWybory
    WHERE ii = 1 AND tag != 'i' GROUP BY rok, gmina, okreg HAVING c > 1
) AS x INNER JOIN gerry.gminy AS g ON x.rok = g.rok AND x.gmina = g.gmina
GROUP BY x.rok, x.gmina ORDER BY (SUM(c) - COUNT(c)) / g.okrGmina * 100 DESC
LIMIT 999