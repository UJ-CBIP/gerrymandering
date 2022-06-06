SELECT s1.gmina, g.nazwa, CONCAT(ROUND(s1.value * 1000, 3), 'E-3') AS H, ROUND(s2.value, 3) AS Delta,
    s2.rank, g.typ, g.typ2010, g.komGmina, g.okrGmina, g.okrGmina - g.gcUnopp AS cPrime
FROM gerry.gerrySuspects AS s1 
INNER JOIN gerry.gerrySuspects AS s2 ON s2.rok = s1.rok AND s2.gmina = s1.gmina AND s2.indicator = 'MalBhattTurn'
INNER JOIN gerry.gminy AS g ON g.rok = s1.rok AND g.gmina = s1.gmina
WHERE s1.indicator = 'MWETurnout' AND s1.rok = 2018
ORDER BY s1.value DESC LIMIT 10;