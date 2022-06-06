require(dplyr)
require(ggplot2)
require(gtools)
require(np)
require(splines)
require(cobs)
require(e1071)
require(purrr)
require(readr)

midpoint <- function(x, y) {
  if (x == Inf && y == -Inf) {
    NA
  } else if (y == -Inf) {
    x
  } else if (x == Inf) {
    y
  } else {
    (x + y) / 2
  }
}

splreg <- function(n, cKnots = 2*n, lambda = -1) {
  nn <- n
  dfit <- filter(wyb, rok < 9999, listOkr == n) %>% select(s, pct, elk)
  dir <- rdirichlet(16384, rep(alpha$alpha[n] / n, n))
  dir0 <- do.call(rbind, apply(dir, 1, function(row) {
    nn <- length(row)
    winner <- which.max(row)
    data.frame(t(sapply(seq(nn), function(i)
      c(s = ifelse(i == winner, 1, 0), pct = row[i], elk = sum(row[-i])^2 / sum(row[-i]^2)))
    ))
  }))

  svmfit <- svm(factor(ceiling(s)) ~ pct + elk, rbind(dfit, dir0), kernel="polynomial")
  
  elkseq <- seq(1, n-1, length=101)
  elkbrk <- c(0, (head(elkseq, -1) + tail(elkseq, -1)) / 2, n)
  pgrid <- expand.grid(pct = seq(1/n, 1/2, length=101), elk = seq(1, n-1, length=101))
  pred <- predict(svmfit, pgrid, decision.values = TRUE)
  pgrid$z <- as.integer(pred) - 1
  pgrid$dec <- attr(pred, "decision.values")
  decbound <- pgrid %>% group_by(elk) %>%
    summarize(bound = midpoint(min(pct * ifelse(z == 1, 1, NA), na.rm=T), max(pct * ifelse(z == 0, 1, NA), na.rm=T)))
  decbound$bound[1] <- 1/2
  decbound$bound[nrow(decbound)] <- 1/n
  elksum <- rbind(dfit, dir0) %>% group_by(elk = cut(elk, breaks = elkbrk)) %>%
    summarize(w = n()) %>% mutate(elk = elkseq[as.integer(elk)])
  decbound <- left_join(decbound, elksum) %>% mutate(w = ifelse(is.na(w), 0, w) + 1)
  # decbound$w[1] <- 65536
  # decbound$w[nrow(decbound)] <- 65536
  sspline <- with(decbound, cobs(
    elk, bound, constraint="decrease", w=w, lambda = lambda, nknots = cKnots,
    pointwise = matrix(c(0, n-1, 1/n, 0, 1, 1/2), ncol = 3, byrow = TRUE)
    ))
  pspline <- data.frame(predict(sspline))

  dfit2 <- filter(wyb, listOkr == n, pct <= 1/2, pct >= 1/n) %>% select(s, pct, elk)
  print(ggplot(pgrid) +
    geom_contour_filled(mapping = aes(x = pct, y = elk, z = z), breaks=c(0, 1, 2)) +
    # geom_point(aes(pct, elk, color=factor(ceiling(s+2))), size=0.5, data=filter(dir0, pct > 1/n, pct < 1/2)) +
    geom_point(aes(pct, elk, color=factor(ceiling(s))), size=0.5, data=filter(dfit2, pct > 1/n, pct < 1/2)) +
    geom_path(aes(bound, elk), data=decbound, col="blue", lwd=1.3) +
    geom_path(aes(fit, z), data=pspline, col="red", lwd=1.3) +
    theme(legend.position = "none")
    )
  sspline
}
# reg10 <- splreg(10)

effTholdRecalc <- function() {
  for (i in 4:12) {
    cobs <- splreg(i)
    wyb[wyb$listOkr == i,]$thold <- predict(cobs, wyb[wyb$listOkr == i,]$elk)[,2]
  }
  wyb$predS <- with(wyb, ifelse(pct >= thold, 1, 0))
  aggregate(abs(wyb$s - wyb$predS), by=list(wyb$listOkr), mean)
}

effTholdSave <- function() {
  hdbc <- odbcConnect("cbip", case="nochange")
  
  sqlQuery(hdbc, "CREATE TEMPORARY TABLE gerry.gerryVT (
    `rok` varchar(6) NOT NULL, `gmina` varchar(6) NOT NULL, `okreg` int NOT NULL, `lista` int NOT NULL,
    `thold` double DEFAULT NULL, `predS` double DEFAULT NULL,
    PRIMARY KEY (`rok`,`gmina`,`okreg`,`lista`)
  )")
  sqlSaveBulk(hdbc, select(wyb, rok, gmina, okreg, lista, thold, predS), "gerry.gerryVT")
  sqlQuery(hdbc, "UPDATE gerry.gerryVT SET gmina = LPAD(gmina, 6, '0');")
  
  sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
    INNER JOIN gerry.gerryVT AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.okreg = q.okreg AND g.lista = q.lista
    SET g.thold = q.thold;")
  
  sqlQuery(hdbc, "UPDATE gerry.gerry AS g
    INNER JOIN (SELECT rok, gmina, koalicja AS lista, AVG(thold) AS t FROM gerry.gerryWybory GROUP BY rok, gmina, koalicja) AS q
    ON g.rok = q.rok AND g.gmina = q.gmina AND g.lista = q.lista
    SET g.avgThold = q.t;")
  
  sqlQuery(hdbc, "UPDATE gerry.gerryHypoSV AS h
    INNER JOIN gerry.gerry AS g ON g.rok = h.rok AND g.gmina = h.gmina AND g.lista = h.lista
    SET h.avgThold = g.avgThold;")
}