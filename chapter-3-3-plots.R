require(DBI)
require(dplyr)
require(ggplot2)
require(GGally)
require(ggpubr)

hdbc <- odbcConnect("cbip", case="nochange")

# Figure 1

ggplot(filter(wyb, mandat==1), aes(x = (zw - runUp) / 1)) +
  geom_density() + xlab(expression(m[k])) + xlim(0, 500) + theme(axis.title.y=element_blank())
