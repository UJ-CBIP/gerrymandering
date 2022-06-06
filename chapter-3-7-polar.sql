SELECT p.gmina, g.nazwa, ROUND(p.esteban, 4) AS esteban, ROUND(p.tiltHalf, 4) AS tiltHalf, ROUND(p.tiltClus, 4) AS tiltClus,
    g.typ, g.typ2010, g.komGmina, g.okrGmina, g.glosGmina
FROM gerry.suspects AS p INNER JOIN gerry.gminy AS g ON p.rok = g.rok AND p.gmina = g.gmina
WHERE p.rok = 2014 ORDER BY p.tiltClus DESC LIMIT 10;