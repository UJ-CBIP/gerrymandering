INSERT INTO gerry.gerry (
    rok, gmina, lista, nazwa, typGminy, typ2010, okr, pct, mandatow, manNT, glos, glosMax, v, s, sNT, cGmina, vGmina, gpct, q,
    cUnopp, vUnopp, gcUnopp, gvUnopp, tag, tag2, rankWojt, bitmask, bitmaskUnopp, members, inkumbent, pretendent,
    cSize, idCore, cCore, vCore, sCore
    )
SELECT g.rok, g.gmina, IFNULL(g.koalicja, g.lista) AS lista, gg.nazwa, gg.typGminy, gg.typ2010,
    SUM(g.okr) AS okr, SUM(g.glos) / SUM(g.glosMax) AS pct, SUM(g.mandatow) AS mandatow, SUM(g.mandatowNT) AS manNT,
    SUM(g.glos) AS glos, SUM(g.glosMax) AS glosMax,
    SUM(g.glos) / SUM(g.glosMax) AS v, SUM(g.mandatow - g.cUnopp) / SUM(g.okr) AS s, SUM(g.mandatowNT - g.cUnopp) / SUM(g.okr) AS sNT,
    gg.okrGmina AS okrGmina, gg.glosGmina AS glosGmina, SUM(g.glos) / gg.glosGmina AS gpct, NULL AS q,
    SUM(g.cUnopp) AS cUnopp, SUM(NULL) AS glosUnopp, gg.gcUnopp, NULL AS gvUnopp,
    GROUP_CONCAT(g.tag) AS tag, GROUP_CONCAT(g.tag2) AS tag2, SUM(g.rankWojt) AS rankWojt,
    SUM(g.bitmask) AS bitmask, SUM(g.bitmaskUnopp) AS bitmaskUnopp, GROUP_CONCAT(g.lista) AS members,
    SUM(g.inkumbent) AS inkumbent, SUM(g.pretendent) AS pretendent, COUNT(*) AS cSize,
    IFNULL(g.koalicja, g.lista) AS idCore, SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.okr, 0)) AS cCore,
    SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.glos, 0)) AS vCore,
    SUM(IF(IFNULL(g.koalicja, g.lista) = g.lista, g.mandatow, 0)) AS sCore
FROM gerry.listy AS g INNER JOIN gerry.gminy AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina
GROUP BY g.rok, g.gmina, IFNULL(g.koalicja, g.lista);

UPDATE gerry.gerry AS g LEFT JOIN (
    SELECT rok, gmina, koalicja AS lista, SUM(ii) AS ii, SUM(IF(listOkr = 1, ii, 0)) AS uii
    FROM gerry.gerryWybory GROUP BY rok, gmina, koalicja
) AS x ON g.rok = x.rok AND g.gmina = x.gmina AND g.lista = x.lista
INNER JOIN gerry.gminy AS gg ON gg.rok = g.rok AND gg.gmina = g.gmina
SET g.ii = IFNULL(x.ii, 0), g.pctII = IFNULL(x.ii, 0) / gg.ai, g.unoppII = x.uii;
