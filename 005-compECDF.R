hdbc <- odbcConnect("cbip", case="nochange")
wyb <- sqlQuery(hdbc, "SELECT * FROM gerry.gerryWybory")
rgCDFs <- sapply(1:max(wyb$listOkr), function(x) ecdf((wyb %>% filter(listOkr == x) %>% select(pct))[,1]))
rgCdfVals <- apply(wyb %>% select(listOkr, pct), 1, function(x) rgCDFs[[x[1]]](x[2]))
wyb$ecdfV <- rgCdfVals
write.csv(wyb %>% select(gmina, okreg, lista, ecdfV), file="d:/gerry/ecdf.csv", row.names=FALSE)
