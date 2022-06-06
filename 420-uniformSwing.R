require(dplyr)
require(readr)
require(purrr)
require(kde1d)

hdbc <- odbcConnect("cbip", case="nochange")

stepIntegrate <- function(stepfun, lower, upper) {
  if (near(upper, lower)) {
    return (stepfun(upper) - stepfun(lower))
  }

  klist <- knots(stepfun)
  klist <- c(lower, klist[between(klist, lower, upper)], upper)

  mu <- klist[-1] - klist[-length(klist)]
  fn <- stepfun(klist[-length(klist)])

  sum(mu * fn) / sum(mu)
}

stepMaximize <- function(stepfun, lower, upper) {
  klist <- knots(stepfun)
  klist <- c(lower, klist[between(klist, lower, upper)], upper)
  max(stepfun(klist[-length(klist)]))
}

partisanBias <- function(swing, r, g, lista1, lista2, method) {
  print(sprintf("gmina %d %d: %d - %d", r, g, lista1, lista2))

  okr1 <- filter(wyb, rok==r, gmina==g, koalicja==lista1, listOkr > 1)$okreg
  okr2 <- filter(wyb, rok==r, gmina==g, koalicja==lista2, listOkr > 1)$okreg
  okr <- intersect(okr1, okr2)
  cc <- length(okr)
  if (cc <= 1) {
    return ()
  }

  wsim <- filter(wyb, rok==r, gmina==g, okreg %in% okr)
  wsim1 <- filter(wsim, koalicja==lista1) %>% select(okreg, glosow, glosOkr, s)
  wsim2 <- filter(wsim, koalicja==lista2) %>% select(okreg, glosow, glosOkr, s)
  
  v1 <- sum(wsim1$glosow) / sum(wsim1$glosOkr)
  v2 <- sum(wsim2$glosow) / sum(wsim2$glosOkr)
  s1 <- sum(wsim1$s)
  s2 <- sum(wsim2$s)
  if (v1 < v2) {
    vmin <- v1; smin <- s1
    vmax <- v2; smax <- s2
  } else {
    vmin <- v2; smin <- s2
    vmax <- v1; smax <- s1
  }

  swing1 <- filter(swing, lista1 == UQ(lista1), lista2 == UQ(lista2))
  sv1 <- stepfun(swing1$v, c(0, swing1$s), right=FALSE)

  swing2 <- filter(swing, lista1 == UQ(lista2), lista2 == UQ(lista1))
  sv2 <- stepfun(swing2$v, c(0, swing2$s), right=FALSE)
  
  svKnots <- sort(c(knots(sv1), knots(sv2)))

  df <- data.frame(
    rok = r, gmina = sprintf("%06d", g), lista1, lista2, method, c = cc, 
    i = seq(1 + 0:length(svKnots)),
    v1 = c(0, svKnots),
    v2 = c(svKnots, 1),
    s1 = c(0, sv1(svKnots)),
    s2 = c(0, sv2(svKnots)),
    bias = c(0, sv1(svKnots) - sv2(svKnots))
  )
  sqlSaveBulk(hdbc, df, "gerry.gerryBiasEx", replace = TRUE)
  
  svbias <- stepfun(svKnots, c(0, sv1(svKnots) - sv2(svKnots)), right=FALSE)
  absbias <- stepfun(svKnots, c(0, abs(sv1(svKnots) - sv2(svKnots))), right=FALSE)
  l2bias <- stepfun(svKnots, c(0, (sv1(svKnots) - sv2(svKnots)) ^ 2), right=FALSE)
  
  bias <- stepIntegrate(svbias, vmin, vmax)
  l1 <- stepIntegrate(absbias, vmin, vmax)
  l2 <- stepIntegrate(l2bias, vmin, vmax)
  lInf <- stepMaximize(absbias, vmin, vmax)

  return (data.frame(
    rok = r, gmina = g, lista1, lista2, method, c = cc, v1 = vmin, v2 = vmax,
    s1 = smin, s2 = smax, mean = bias, l1, l2, lInf
  ))
}

pbGmina <- function(r, g, method) {
  swing <- sqlQuery(hdbc,
    sprintf("SELECT * FROM gerry.gerrySwing WHERE rok = %d AND gmina = %d AND method = '%s'", r, g, method)
  )
  lst <- filter(gdf, rok == r, gmina == g, !is.na(v), okr > 1)$lista
  grid <- expand.grid(l1 = lst, l2 = lst) %>% filter(l1 != l2)
  df <- pmap_df(grid, function(l1, l2) try(partisanBias(swing, r, g, l1, l2, method)))
  sqlSaveBulk(hdbc, df, "gerry.gerryBias", replace=TRUE)
}

hdbc <- odbcConnect("cbip", case="nochange")
select(gdf, rok, gmina) %>% unique() %>%
  pwalk(function(rok, gmina) pbGmina(rok, gmina, 'probit'))
sqlQuery(hdbc, "UPDATE gerry.gerryBias SET gmina = LPAD(gmina, 6, '0');")
