INSERT INTO gerry.malapp
SELECT g.rok, g.gmina, t.nazwa, 0 AS upraw, COUNT(*) AS cc, SUM(vv) AS v,
	MAX(v*c) - MIN(v*c) AS xRange,
	MAX(v) / MIN(v) AS xRatio,
	AVG(ABS(v*c - 1)) AS meanDev,
	SQRT(AVG(POWER(v*c - 1, 2))) AS stdDev,
	((COUNT(*)+1.0)/(COUNT(*)-1.0)) - ((SUM(vRank*v) / (COUNT(*)*(COUNT(*)-1)*AVG(v)))*2.0) as gini,
	SUM(IF(vRank > FLOOR(c / 2 - 0.1), v, 0)) AS dauerKelsay,
	SUM(IF(ABS(v*c - 1) > 0.15, 1, 0)) / c AS clem10pct,
	1 / (1 + SQRT(AVG(POWER(v*c - 1, 2)))) AS schubertPress,
	1 - SQRT(1 - EXP(AVG(LN(v*c)))) AS kaiser,
	-SUM(v * LN(v)) / LN(c) AS shannon,
	-LN(SUM(POWER(v, 2))) / LN(c) AS renyi2,
	1 / SUM(v*v) / c AS normEND,
	SUM(ABS(v*c - 1)) / 2 AS loosemoreHanby,
	SQRT(SUM(POWER(v*c - 1, 2)) / 2) AS gallagher,
	MAX(ABS(v*c - 1)) AS chebyshev,
	SUM(vv) * SUM(POWER(v - 1/c, 2) / v) AS chiSq,
	1 - c*SUM(POWER(v, 2)) AS taageperaShugart,
	SUM(v/c) / SUM(v*v) AS coxShugart,
	SUM(v/c) / SQRT(SUM(v*v) * SUM(1/(c*c))) AS cosine,
	ACOS(SUM(SQRT(v/c))) AS bhatt,
	SUM(v * LN(v*c)) AS kullbackLeibler,
	-SUM(1/c * LN(v*c)) AS kullbackLeiblerR,
	-SUM(v / (v*c) * LN(v*c)) AS alphaDiv1,
	SUM(1/c * (v*c) * LN(v*c)) AS alphaDiv1r,
	1/2 * SUM(v * (POWER(v*c, -2) - 1)) AS alphaDiv2,
	1/2 * SUM(1/c * (POWER(v*c, 2) - 1)) AS alphaDiv2r,
	-1/c * SUM(LN(v*c)) AS theilL,
	1/c * SUM(v*c * LN(v*c)) AS theilT
FROM gerry.okregi AS g INNER JOIN gerry.gminy AS t ON t.rok = g.rok AND t.gmina = g.gmina
WHERE g.v IS NOT NULL GROUP BY g.rok, g.gmina HAVING cc > 7;

INSERT INTO gerry.malapp
SELECT g.rok, g.gmina, t.nazwa, 1 AS upraw, COUNT(*) AS cc, SUM(ww) AS v,
	MAX(w*c) - MIN(w*c) AS xRange,
	MAX(w) / MIN(w) AS xRatio,
	AVG(ABS(w*c - 1)) AS meanDev,
	SQRT(AVG(POWER(w*c - 1, 2))) AS stdDev,
	((COUNT(*)+1.0)/(COUNT(*)-1.0)) - ((SUM(wRank*w) / (COUNT(*)*(COUNT(*)-1)*AVG(w)))*2.0) as gini,
	SUM(IF(wRank > FLOOR(c / 2 - 0.1), w, 0)) AS dauerKelsay,
	SUM(IF(ABS(w*c - 1) > 0.15, 1, 0)) / c AS clem10pct,
	1 / (1 + SQRT(AVG(POWER(w*c - 1, 2)))) AS schubertPress,
	1 - SQRT(1 - EXP(AVG(LN(w*c)))) AS kaiser,
	-SUM(w * LN(w)) / LN(c) AS shannon,
	-LN(SUM(POWER(w, 2))) / LN(c) AS renyi2,
	1 / SUM(w*w) / c AS normEND,
	SUM(ABS(w*c - 1)) / 2 AS loosemoreHanby,
	SQRT(SUM(POWER(w*c - 1, 2)) / 2) AS gallagher,
	MAX(ABS(w*c - 1)) AS chebyshev,
	SUM(ww) * SUM(POWER(w - 1/c, 2) / w) AS chiSq,
	1 - c*SUM(POWER(w, 2)) AS taageperaShugart,
	SUM(w/c) / SUM(w*w) AS coxShugart,
	SUM(w/c) / SQRT(SUM(w*w) * SUM(1/(c*c))) AS cosine,
	ACOS(SUM(SQRT(w/c))) AS bhatt,
	SUM(w * LN(w*c)) AS kullbackLeibler,
	-SUM(1/c * LN(w*c)) AS kullbackLeiblerR,
	-SUM(w / (w*c) * LN(w*c)) AS alphaDiv1,
	SUM(1/c * (w*c) * LN(w*c)) AS alphaDiv1r,
	1/2 * SUM(w * (POWER(w*c, -2) - 1)) AS alphaDiv2,
	1/2 * SUM(1/c * (POWER(w*c, 2) - 1)) AS alphaDiv2r,
	-1/c * SUM(LN(w*c)) AS theilL,
	1/c * SUM(w*c * LN(w*c)) AS theilT
FROM gerry.okregi AS g INNER JOIN gerry.gminy AS t ON t.rok = g.rok AND t.gmina = g.gmina
WHERE g.w IS NOT NULL GROUP BY g.rok, g.gmina HAVING cc > 7;