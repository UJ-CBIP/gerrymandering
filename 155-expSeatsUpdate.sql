CREATE TEMPORARY TABLE gerry.gerryExpSeats (
  `rok` varchar(6) NOT NULL,
  `gmina` varchar(6) NOT NULL,
  `okreg` int NOT NULL,
  `lista` int NOT NULL,
  `expect` double DEFAULT NULL,
  PRIMARY KEY (`rok`,`gmina`,`okreg`,`lista`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'd://gerry//expseats//seats3.csv' INTO TABLE gerry.gerryExpSeats
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n' IGNORE 0 ROWS;

UPDATE gerry.gerryExpSeats AS e INNER JOIN (
    SELECT rok, gmina, okreg, SUM(expect) AS s FROM gerry.gerryExpSeats GROUP BY rok, gmina, okreg
) AS x ON x.rok = e.rok AND x.gmina = e.gmina AND x.okreg = e.okreg SET expect = expect /s;

UPDATE gerry.gerryWybory AS w INNER JOIN gerry.gerryExpSeats AS s ON
    w.rok = s.rok AND w.gmina = s.gmina AND w.okreg = s.okreg AND w.koalicja = s.lista
SET w.expectS = s.expect;

DROP TEMPORARY TABLE gerry.gerryExpSeats;