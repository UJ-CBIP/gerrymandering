CREATE TABLE gerry.okregi
SELECT g.rok, g.gmina, g.okreg, g.listOkr AS n, g.glosOkr AS vv, g.okrUpraw AS ww,
    NULL AS v, NULL AS w, g.zw AS v1, g.runUp AS v2, g.tie,
    g.eAlpha, SUM(g.ii) AS ii, SUM(IF(g.tag != 'i', g.ii, 0)) AS iiOpozycja,
    NULL, NULL, NULL, NULL, NULL, o.granice
FROM gerry.gerryWybory AS g
LEFT JOIN common.wybKod AS k ON k.rok = g.rok AND k.typ = 'SMD'
LEFT JOIN wybory.wybory AS w ON w.akcja = k.akcja
LEFT JOIN wybory.teryt AS t ON t.teryt = g.gmina AND wybory.dateBetween(w.data, t.dataOd, t.dataDo)
LEFT JOIN wybory.okregi AS o ON o.jednostka = t.guid AND o.organ = 'RDA' AND o.subKod = 0 AND o.kadencja = w.kadencja AND o.subKadencja = 1 AND o.okreg = g.okreg
GROUP BY g.rok, g.gmina, g.okreg;

UPDATE gerry.okregi SET w = NULL WHERE n <= 1;

UPDATE gerry.okregi AS g INNER JOIN (
    SELECT rok, gmina, SUM(vv) AS v, SUM(ww) AS w FROM gerry.okregi GROUP BY rok, gmina
) AS x ON x.rok = g.rok AND x.gmina = g.gmina
SET g.vNorm = g.vv / x.v, g.wNorm = g.ww / x.w;

UPDATE gerry.okregi AS g INNER JOIN (
    SELECT rok, gmina, okreg, v, w, COUNT(v) OVER (PARTITION BY rok, gmina) AS c,
        ROW_NUMBER() OVER (PARTITION BY rok, gmina ORDER BY v DESC) AS vRank,
        ROW_NUMBER() OVER (PARTITION BY rok, gmina ORDER BY w DESC) AS wRank,
        SUM(v) OVER (PARTITION BY rok, gmina ORDER BY v DESC) AS vLorenz,
        SUM(w) OVER (PARTITION BY rok, gmina ORDER BY w DESC) AS wLorenz
    FROM gerry.okregi ORDER BY rok, gmina, okreg
) AS x ON x.rok = g.rok AND x.gmina = g.gmina AND x.okreg = g.okreg
SET g.c = x.c, g.vRank = x.vRank, g.wRank = x.wRank, g.vLorenz = x.vLorenz, g.wLorenz = x.wLorenz;