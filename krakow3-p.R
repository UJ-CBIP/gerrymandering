require(dplyr)
select <- dplyr::select
hdbc <- odbcConnect("cbip", case="nochange")

gdf <- sqlQuery(hdbc, "SELECT * FROM gerry.gerry")
gdf14 <- subset(gdf, rok == "2014")
gdf18 <- subset(gdf, rok == "2018")

fit <- inner_join(inner_join(
  filter(select(wyb99, rok, gmina, okreg, lista = koalicja, n = listOkr), n > 1),
  select(gdf, rok, gmina, lista, v = pct, q)
),
transmute(filter(alpha, rok == 2014), rok = 9999, n = n, alpha = beta0, beta = beta1)
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

sqlQuery(hdbc, "DELETE FROM gerry.gerryP WHERE rok = 9999;")
sqlSaveBulk(hdbc, fit, "gerry.gerryP")
sqlQuery(hdbc, "UPDATE gerry.gerryP SET gmina = LPAD(gmina, 6, '0');")
sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
  INNER JOIN gerry.gerryP AS q ON g.rok = q.rok AND g.gmina = q.gmina AND g.okreg = q.okreg AND g.koalicja = q.lista
  SET g.expect = q.p WHERE g.rok = 9999;")
