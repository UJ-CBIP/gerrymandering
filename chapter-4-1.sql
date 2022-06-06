SELECT rok, zabor, ROUND(AVG(psi), 3) AS psi, ROUND(AVG(psi0), 3) AS psi0,
    ROUND(AVG(svDirichlet), 3) AS P, ROUND(AVG(svKernel), 3) AS Phi, ROUND(AVG(svOutlier), 3) AS U,
    ROUND(AVG(biasL1), 3) AS bias, ROUND(AVG(effGap), 3) AS omega,
    ROUND(AVG(monotonic), 3) AS eta, CONCAT(ROUND(AVG(malTurnout) * 1000, 2), 'E-3') AS H
FROM (
    SELECT s.*, g.typ, g.typWyb, w.nazwa AS woj, g.zabor FROM gerry.suspects AS s
        INNER JOIN wybory.gminy AS g ON g.rok = s.rok AND g.teryt = s.gmina
        LEFT JOIN wybory.wojew AS w ON w.rok = g.rok AND w.guid = g.wojew
) AS x GROUP BY rok;

SELECT s.gmina, s.nazwa, RPAD(ROUND(s.psi, 4), 6, '0') AS psi, RPAD(ROUND(s.psi0, 3), 5, '0') AS psi0,
    RPAD(ROUND(s.monotonic, 3), 5, '0') AS eta, CONCAT(ROUND(s.malTurnout * 1000, 1), 'E-3') AS H, g.typ, g.typ2010 AS sw,
    g.komGmina AS n, g.okrGmina AS c, g.glosGmina AS v, g.gcUnopp AS bk, ROUND(g.elk, 3) AS elk,
    CONCAT(ROUND(x.v * 100, 1), '%') AS v, x.okr, x.mandatow - x.cUnopp AS s, ROUND(x.expectS * x.okr, 2) AS expectS, ROUND((x.mandatow - x.cUnopp) - x.expectS * x.okr, 2) AS deltaS,
    ROUND(i.s - i.expectS, 3) AS deltaI
FROM gerry.suspects AS s
INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina
LEFT JOIN gerry.gerry AS x ON x.rok = s.rok AND x.gmina = s.gmina AND x.rankMan = 1
LEFT JOIN gerry.gerry AS i ON i.rok = s.rok AND i.gmina = s.gmina AND i.tag = 'i'
WHERE s.rok = 2014 GROUP BY s.rok, s.gmina ORDER BY s.psi ASC LIMIT 50;

SELECT lista, CONCAT(ROUND(v * 100, 1), '%') AS v, CONCAT(ROUND(gpct * 100, 1), '%') AS vv,
    CONCAT(ROUND(normV * 100, 1), '%') AS w, okr AS c, mandatow - cUnopp AS s, ROUND(expectS * okr, 2) AS expectS,
    ROUND(avgElk, 2) AS elk, REPLACE(ROUND(avgThold, 3), '0.', '.') AS thold, cUnopp AS bk,
    ROUND(pValue, 3) AS P, ROUND(phi, 3) AS phi, ROUND(uqNorm, 3) AS u, CONCAT(ROUND(entTurnout * 1000, 2), 'E-3') AS malApp,
    tag
FROM gerry.gerry WHERE rok = 2014 AND gmina = 060611;
