UPDATE gerry.gerryWybory AS w
INNER JOIN gerry.gammaFit AS g ON g.rok = w.rok AND g.n = w.listOkr
SET w.k = g.k, w.theta = g.theta, w.eAlpha = g.k * g.theta;