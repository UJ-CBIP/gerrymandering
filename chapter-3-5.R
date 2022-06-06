require(DBI)
require(dplyr)
require(ggplot2)

hdbc <- odbcConnect("cbip", case="nochange")
mal <- sqlQuery(hdbc, "SELECT * FROM gerry.malapp")

# Figure 1

plot1 <- ggplot(filter(mal, rok==2014, upraw==0)) + geom_density(aes(x=bhatt)) +
  geom_vline(aes(xintercept = median(filter(mal, rok==2014, upraw==0)$bhatt)), lwd=sqrt(1.6), col="red") +
  xlab(expression(Delta)) + ylab("")

plot2 <- ggplot(filter(mal, rok==2014, upraw==1)) + geom_density(aes(x=bhatt)) +
  geom_vline(aes(xintercept = median(filter(mal, rok==2014, upraw==1)$bhatt)), lwd=sqrt(1.6), col="red") +
  xlab(expression(Delta)) + ylab("")

ggarrange(plotlist=list(plot1, plot2), ncol=2)

# dims: 640 x 280

# Figure 2

dbcon <- dbConnect(odbc::odbc(), "cbip", timeout = 300)
suspects <- dbGetQuery(dbcon, "SELECT * FROM gerry.suspects")
ggplot(suspects) + geom_density(aes(malPop), size=1.1) + xlab(expression(H)) + ylab("")

# Table 6

hdbc <- odbcConnect("cbip", case="nochange")
tbl6 <- sqlQuery(hdbc, "SELECT s.gmina, s.nazwa, CONCAT(ROUND(s.value * 1000, 3), 'E-3') AS val, ROUND(m.bhatt, 3) AS bhatt,
  RANK() OVER (PARTITION BY s.rok ORDER BY m.bhatt DESC) AS rnk, g.typ, g.typ2010, komGmina, okrGmina, m.c, glosGmina
  FROM gerry.gerrySuspects AS s INNER JOIN gerry.malapp AS m ON m.rok = s.rok AND m.gmina = s.gmina AND m.upraw = 0
  INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina
  WHERE s.indicator = 'MWETurnout' AND s.rok = 2014
  ORDER BY s.value DESC LIMIT 20;")

# Figure 3

hdbc <- odbcConnect("cbip", case="nochange")
f3df <- sqlQuery(hdbc, "SELECT s.gmina, s.nazwa, s.value AS H, m.bhatt AS Delta
  FROM gerry.gerrySuspects AS s INNER JOIN gerry.malapp AS m ON m.rok = s.rok AND m.gmina = s.gmina AND m.upraw = 0
  WHERE s.indicator = 'MWETurnout' AND s.rok = 2014;")

ggplot(f3df) + geom_point(aes(Delta, H)) + xlab(expression(Delta))

# dims: 640 x 400
