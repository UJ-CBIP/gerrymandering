UPDATE gerry.gerry AS g INNER JOIN (
    SELECT rok, gmina, koalicja AS lista, AVG(expectS) AS s FROM gerry.gerryWybory WHERE listOkr > 1 GROUP BY rok, gmina, koalicja
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista SET g.expectS = x.s;

UPDATE gerry.gerry AS g
    INNER JOIN gerry.gerrySDist AS sd ON sd.rok = g.rok AND sd.gmina = g.gmina AND sd.lista = g.lista AND sd.s = g.manNT - g.cUnopp
SET g.pExact = sd.prob, g.pLess = sd.cdf, g.pMore = 1 - sd.cdf + sd.prob, g.pValue = LEAST(sd.cdf, 1 - sd.cdf + sd.prob);

UPDATE gerry.gerryHypoSV AS g
    INNER JOIN gerry.gerrySDist AS sd ON sd.rok = g.rok AND sd.gmina = g.gmina AND sd.lista = g.lista AND sd.s = g.man
SET g.pExact = sd.prob, g.pLess = sd.cdf, g.pMore = 1 - sd.cdf + sd.prob, g.pValue = LEAST(sd.cdf, 1 - sd.cdf + sd.prob);

UPDATE gerry.gerryHypoSV AS g
    INNER JOIN gerry.gerrySDist AS sd ON sd.rok = g.rok AND sd.gmina = g.gmina AND sd.lista = g.lista AND sd.s = FLOOR(g.man)
SET g.pExact = 0, g.pLess = sd.cdf, g.pMore = 1 - sd.cdf, g.pValue = LEAST(sd.cdf, 1 - sd.cdf)
WHERE MOD(g.man, 1) != 0;