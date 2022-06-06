UPDATE gerry.gerryWybory AS w INNER JOIN (
    SELECT rok, gmina, okreg, koalicja,
        pct / SUM(pct) OVER (PARTITION BY rok, gmina, koalicja) AS glosNorm,
        glosOkr / SUM(glosOkr) OVER (PARTITION BY rok, gmina, koalicja) AS okrNorm,
        okrUpraw / SUM(okrUpraw) OVER (PARTITION BY rok, gmina, koalicja) AS uprawNorm
    FROM gerry.gerryWybory WHERE listOkr > 1
) AS x ON x.rok = w.rok AND x.gmina = w.gmina AND x.koalicja = w.koalicja AND x.okreg = w.okreg
SET w.glosNorm = x.glosNorm, w.okrNorm = x.okrNorm, w.uprawNorm = x.uprawNorm;

UPDATE gerry.gerry AS g INNER JOIN (
    SELECT rok, gmina, koalicja AS lista, COUNT(*) AS c,
        -SUM(glosNorm * okrNorm * LOG(okrNorm)) AS went,
        -SUM(glosNorm * okrNorm * LOG(okrNorm)) + SUM(okrNorm * LOG(okrNorm)) / COUNT(*) AS ent,
        -SUM(glosNorm * uprawNorm * LOG(uprawNorm)) AS went2,
        -SUM(glosNorm * uprawNorm * LOG(uprawNorm)) + SUM(uprawNorm * LOG(uprawNorm)) / COUNT(*) AS ent2
    FROM gerry.gerryWybory WHERE listOkr > 1
    GROUP BY rok, gmina, koalicja
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
SET g.entTurnout = x.ent, g.entPop = x.ent2, g.wentTurnout = x.went, g.wentPop = x.went2;