require(dplyr)
require(tidyr)
require(fitdistrplus)
hdbc <- odbcConnect("cbip", case="nochange")

wyb14W <- subset(wyb14, TRUE, c("gmina", "okreg", "lista", "listOkr", "pct")) %>%
  pivot_wider(names_from = lista, values_from = pct)
wyb18w <- subset(wyb18, TRUE, c("gmina", "okreg", "lista", "listOkr", "pct")) %>%
  pivot_wider(names_from = lista, values_from = pct)

doDirFit <- function(argRok)
  data.frame(t(sapply (2:max(filter(wyb, rok == argRok)$n), function(i) {
    print(i)
    alpha <- sum(coef(fitdist(filter(wyb, rok == argRok & n == i)$p, "beta", method="mge", start=list(shape1 = 1, shape2 = i-1))))
    c(rok = argRok, n = i, alpha = alpha, c = nrow(filter(wyb, rok == argRok & n == i)) / i)
  })))
vfit14 <- doDirFit(2014)
vfit18 <- doDirFit(2018)
sqlSaveBulk(hdbc, vfit14, "gerry.distribDirV_okr", replace = TRUE)
sqlSaveBulk(hdbc, vfit18, "gerry.distribDirV_okr", replace = TRUE)