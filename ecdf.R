require(kde1d)

hdbc <- odbcConnect("cbip", case="nochange")
for (i in 2:max(wyb14$listOkr)) {
  fit <- kde1d(filter(wyb, rok == 2014, listOkr == i)$pct)
  df <- data.frame(rok = 2014, n = i, v = seq(0, 1, 0.0001))
  df$cdf <- pkde1d(df$v, fit)
  df$q <- qkde1d(df$v, fit)
  sqlSaveBulk(hdbc, select(df, rok, n, x = v, y = cdf), "gerry.ecdfV", replace = TRUE)
  sqlSaveBulk(hdbc, select(df, rok, n, x = v, y = q), "gerry.quantileV", replace = TRUE)
}
for (i in 2:max(wyb18$listOkr)) {
  fit <- kde1d(filter(wyb, rok == 2018, listOkr == i)$pct)
  df <- data.frame(rok = 2018, n = i, v = seq(0, 1, 0.0001))
  df$cdf <- pkde1d(df$v, fit)
  df$q <- qkde1d(df$v, fit)
  sqlSaveBulk(hdbc, select(df, rok, n, x = v, y = cdf), "gerry.ecdfV", replace = TRUE)
  sqlSaveBulk(hdbc, select(df, rok, n, x = v, y = q), "gerry.quantileV", replace = TRUE)
}
sqlQuery(hdbc, "UPDATE gerry.ecdfV SET y = x WHERE x IN (0, 1);")
sqlQuery(hdbc, "UPDATE gerry.quantileV SET y = x WHERE x IN (0, 1);")
