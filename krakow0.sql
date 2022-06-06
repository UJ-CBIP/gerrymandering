UPDATE gerry.krakow SET party = SUBSTRING_INDEX(file, '_', 1) WHERE alg = 'SSz' AND party IS NULL;
UPDATE gerry.krakow SET seats = SUBSTRING_INDEX(SUBSTRING_INDEX(file, '_', 2), '_', -1) WHERE alg = 'SSz' AND seats IS NULL;
UPDATE gerry.krakow SET widelki = SUBSTRING_INDEX(file, '_', -1) WHERE alg = 'SSz' AND file LIKE '%\_0._' AND widelki IS NULL;
UPDATE gerry.krakow SET widelki = 0.5 WHERE alg = 'SSz' AND widelki IS NULL;
UPDATE gerry.krakow SET margin = SUBSTRING_INDEX(file, '_', -1) WHERE alg = 'SSz' AND file LIKE '%\_1._' AND margin IS NULL;
UPDATE gerry.krakow SET margin = SUBSTRING_INDEX(file, '_', -1) WHERE alg = 'SSz' AND file LIKE '%\_1.__' AND margin IS NULL;
UPDATE gerry.krakow SET margin = 1 WHERE alg = 'SSz' AND margin IS NULL;

UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.upraw = o.pop14, k.glos = o.glosW14;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.pis = o.pis14 * k.glos;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.po = o.po14 * k.glos;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.jm = o.jm14 * k.glos;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.kpi = o.kpi14 * k.glos;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.korwin = o.korwin14 * k.glos;
UPDATE gerry.krakow AS k INNER JOIN gerry.krakowObwody AS o ON o.obwod = k.obwod SET k.gibala = o.gibala14 * k.glos;

DROP TEMPORARY TABLE IF EXISTS gerry.krakowTmp;
CREATE TEMPORARY TABLE gerry.krakowTmp (obwod INT, okreg INT);

LOAD DATA LOCAL INFILE 'd://gerry//krakowRes//po_34_1.1_krakow_2010.txt' INTO TABLE gerry.krakowTmp
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n' IGNORE 1 ROWS;

INSERT INTO gerry.krakow
SELECT 'SSz' AS alg, 'po_34_1.1_krakow_2010' AS file, 'PO', NULL AS seats, 0.5, 1.1, 126979, k.obwod, k.okreg,
    (x.pop14) AS upraw, (x.glosW14) AS glos, (x.pis14 * x.glosW14) AS pis, (x.po14 * x.glosW14) AS po,
    (x.jm14 * x.glosW14) AS jm, (x.kpi14 * x.glosW14) AS kpi, (x.korwin14 * x.glosW14) AS korwin, (x.gibala14 * x.glosW14) AS gibala,
    NULL AS inni, NULL, NULL, NULL, NULL, NULL 
FROM gerry.krakowTmp AS k INNER JOIN gerry.krakowObwody AS x ON x.obwod = k.obwod;

UPDATE gerry.krakow SET inni = glos - pis - po - jm - kpi - korwin - gibala WHERE inni IS NULL;
