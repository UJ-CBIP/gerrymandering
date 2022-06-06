svplot <- function(gmina) {
  q <- sprintf("SELECT b.v1, b.s1, b.s2, g1.v AS vv1, g2.v AS vv2 FROM gerry.gerryBiasEx AS b INNER JOIN gerry.gerry AS g1 ON g1.rok = b.rok AND g1.gmina = b.gmina AND g1.lista = b.lista1 INNER JOIN gerry.gerry AS g2 ON g2.rok = b.rok AND g2.gmina = b.gmina AND g2.lista = b.lista2 WHERE b.rok = 2014 AND b.gmina = %d AND b.rank1  = 1 AND b.rank2 = 2 AND b.method = 'probit';", gmina)
  df <- rbind(sqlQuery(hdbc, q), c(1, 1, 1, NA, NA))
  ggplot(df) + geom_step(aes(v1, s1), col="blue", size=1.2) +
    geom_step(aes(v1, s2), col="red", size=1.2) +
    geom_vline(aes(xintercept = vv1), col="blue", lwd=1.2, linetype="dashed") +
    geom_vline(aes(xintercept = vv2), col="red", lwd=1.2, linetype="dashed") +
    xlim(0, 1) + coord_cartesian(xlim = c(df$v1[2]-0.01, tail(df$v1, n=2)[1]))
}