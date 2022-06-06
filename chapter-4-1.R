hdbc <- odbcConnect("cbip")
sdf <- sqlQuery(hdbc, "SELECT g.*, s.psi, s.psi0 FROM gerry.suspects AS s
  INNER JOIN gerry.gminy AS g ON g.rok = s.rok AND g.gmina = s.gmina")

sdf1 <- sqlQuery(hdbc, "SELECT s.*, z.value AS old, CUME_DIST() OVER (ORDER BY z.value ASC) AS old_ecdf FROM gerry.suspects AS s
  INNER JOIN gerry.zzzGerrySuspects AS z ON z.gmina = s.gmina AND z.indicator = 'Psi'
  WHERE rok = 2014;")

ggplot(sdf) + geom_density(aes(psi0)) + xlab(expression(Psi*"'")) + ylab("")
ggplot(sdf) + geom_density(aes(psi)) + xlab(expression(Psi)) + ylab("")

sdf2 <- sqlQuery(hdbc, "SELECT s.*, g.typ, g.typWyb, w.nazwa AS woj, g.zabor FROM gerry.suspects AS s
  INNER JOIN wybory.gminy AS g ON g.rok = s.rok AND g.teryt = s.gmina
  LEFT JOIN wybory.wojew AS w ON w.rok = g.rok AND w.guid = g.wojew")

model <- npreg(
  psi ~ typ + glosGmina + okrGmina + elk + factor(is.na(lstIncumbent)) + factor(partisan) + compet,
  filter(sdf, rok==2014))

require(gtools)
require(mgcv)
require(mgcViz)

# logitx <- function(x) logit(replace(x, x <= 0, 0.0001))
# model <- gam(psi ~ factor(typ) + s(glosGmina) + factor(okrGmina) + s(elk) + factor(is.na(lstIncumbent)) + factor(partisan) + s(compet), "gaussian", filter(sdf, rok==2014))

sdf$okr21 <- sdf$okrGmina >= 21
sdf$okr23 <- sdf$okrGmina >= 23
modelProbit <- gam(logit(psi) ~ factor(typ) + factor(typ2010) + s(glosGmina) + factor(okr21) + factor(okr23) + s(elk) + factor(is.na(lstIncumbent)) + factor(partisan) + s(compet), gaussian(), filter(sdf, rok==2014))
model <- modelProbit

plot(getViz(model), allTerms = F, select = 1) +
  l_points() + l_fitLine(linetype = 1) + l_ciLine(linetype = 3) + l_ciBar() + l_rug() +
  theme_grey() + xlab(expression(w[k])) + ylab(expression(s[w](w[k])))
plot(getViz(model), allTerms = F, select = 3) +
  l_points() + l_fitLine(linetype = 1) + l_ciLine(linetype = 3) + l_ciBar() + l_rug() +
  theme_grey() + xlab(expression(w[k])) + ylab(expression(s[w](w[k])))
