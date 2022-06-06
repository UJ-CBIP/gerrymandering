UPDATE gerry.gerryWybory AS w
INNER JOIN gerry.krakowExpSeats AS x ON x.klasa = w.klasa AND x.lista = w.lista
SET w.expectS = x.expect WHERE w.rok = 9999