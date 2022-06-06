require(dplyr)
require(ggplot2)

k2means <- function(x) {
  if (length(x) == 2) {
    ret <- c(max(x), min(x))
  } else {
    x2 <- kmeans(matrix(x, ncol=1), 2)$centers
    ret <- c(max(x2), min(x2))
  }
  ret
}

hdbc <- odbcConnect("cbip", case="nochange")
wbp <- sqlQuery(hdbc, "SELECT * FROM gerry.wbp WHERE normPop < 1")
cmeans <- do.call(data.frame, aggregate(v ~ rok + gmina + lista, wbp, k2means))
colnames(cmeans)[4:5] <- c("cluster1", "cluster2")
sqlSaveBulk(hdbc, cmeans, "gerry.tiltKMeansWBP")
sqlQuery(hdbc, "UPDATE gerry.tiltKMeansWBP SET gmina = LPAD(gmina, 6, '0');")