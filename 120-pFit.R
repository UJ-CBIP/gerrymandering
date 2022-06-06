require(dplyr)
select <- dplyr::select
hdbc <- odbcConnect("cbip", case="nochange")

fit <- inner_join(inner_join(
    filter(select(wyb, rok, gmina, okreg, lista = koalicja, n = listOkr), n > 1),
    select(gdf, rok, gmina, lista, v = pct, q)
    ),
  select(alpha, rok, n, alpha = beta0, beta = beta1)
  )
fit <- fit %>% mutate(p = qbeta(q, alpha, beta)) %>% mutate(renorm = 1)
fit0 <- fit

# err <- fit %>% group_by(rok, gmina) %>% summarize(dist = 1)

for (i in 1:25) {
  print(sprintf("%d %f %f %f", i, mean(fit$renorm), min(fit$renorm), max(fit$renorm)))
  fit <- inner_join(select(fit, -renorm), select(fit, -renorm) %>% group_by(rok, gmina, okreg) %>%
                      summarize(renorm = sum(p))) %>% mutate(p = p / renorm)
  fit <- inner_join(select(fit, -renorm), select(fit, -renorm) %>% group_by(rok, gmina, lista) %>%
                      summarize(renorm = mean(p) / mean(v))) %>%
                      mutate(renorm = ifelse(is.na(renorm), 1, renorm)) %>%
                      mutate(p = p / renorm)
#  err <- fit %>% group_by(rok, gmina, lista) %>% summarize(dist = mean(p) - mean(v)) %>%
#    group_by(rok, gmina) %>% summarize(dist = mean(abs(dist))) %>% inner_join(err %>% rename(dist0 = dist))
}

fit <- fit %>% mutate(renorm0 = renorm)
fit <- inner_join(select(fit, -renorm), select(fit, -renorm) %>% group_by(rok, gmina, okreg) %>%
                    summarize(renorm = sum(p))) %>% mutate(p = p / renorm)
plot(density((fit %>% group_by(rok, gmina, lista) %>% summarise(renorm = mean(renorm0)))$renorm), main="renorm")

sqlQuery(hdbc, "TRUNCATE TABLE gerry.gerryP;")
sqlSaveBulk(hdbc, fit, "gerry.gerryP")
sqlQuery(hdbc, "UPDATE gerry.gerryP SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
  INNER JOIN gerry.gerryP AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.okreg = q.okreg AND g.koalicja = q.lista
  SET g.expect = q.p;")

pOrd <- dplyr::select(fit, rok, gmina, okreg, n, lista, p) %>% group_by(rok, gmina, okreg) %>%
  summarize(n = mean(n), p1 = nth(p, 1, -p), p2 = nth(p, 2, -p), p3 = nth(p, 3, -p), p4 = nth(p, 4, -p), p5 = nth(p, 5, -p), p6 = nth(p, 6, -p), p7 = nth(p, 7, -p), p8 = nth(p, 8, -p), p9 = nth(p, 9, -p), p10 = nth(p, 10, -p), p11 = nth(p, 11, -p), p12 = nth(p, 12, -p)) %>%
  group_by(rok, n) %>% summarize(p1 = mean(p1), p2 = mean(p2), p3 = mean(p3), p4 = mean(p4), p5 = mean(p5), p6 = mean(p6), p7 = mean(p7), p8 = mean(p8), p9 = mean(p9), p10 = mean(p10), p11 = mean(p11), p12 = mean(p12))

doDirFit <- function(argRok)
  data.frame(t(sapply (2:max(filter(fit, rok == argRok)$n), function(i) {
    print(i)
    alpha <- sum(coef(fitdist(filter(fit, rok == argRok & n == i)$p, "beta", method="mge", start=list(shape1 = 1, shape2 = i-1))))
    c(rok = argRok, n = i, alpha = alpha, c = nrow(filter(fit, rok == argRok & n == i)) / i)
  })))
pfit14 <- doDirFit(2014)
pfit18 <- doDirFit(2018)
sqlSaveBulk(hdbc, pfit14, "gerry.distribDirP", replace = TRUE)
sqlSaveBulk(hdbc, pfit18, "gerry.distribDirP", replace = TRUE)