require(dplyr)
require(igraph)

hdbc <- odbcConnect("cbip", case="nochange")
kdf <- sqlQuery(hdbc, "SELECT * FROM gerry.koalicje")
lst <- sqlQuery(hdbc, "SELECT * FROM gerry.listy")

colbar <- c("yellow", "green")

apply(unique(select(lst, 1:2)), 1, function(x) {
  vList <- subset(lst, rok==x[1] & gmina==x[2]) %>% select(lista, major)
  vMajor <- filter(vList, major == 1)$lista
  edgeList <- subset(kdf, rok==x[1] & gmina==x[2])
  graf <- graph_from_data_frame(edgeList[,3:4], directed=FALSE, vertices=vList)
  V(graf)$color <- colbar[V(graf)$major+1]
  cliq <- lapply(max_cliques(graf, min=2), function(x) strtoi(names(unlist(x))))
  # dg <- decompose.graph(graf)
  if (length(cliq) > 0) {
    coreCliqs <- lapply(vMajor, function(v) {
      incliq <- cliq[sapply(cliq, function(x) v %in% x)]
      if (length(incliq) > 0) {
        cc <- vList$lista
        for (i in 1:length(incliq)) {
          cc <- intersect(cc, incliq[[i]])
        }
        cc
      } else {
        v
      }
    })
    names(coreCliqs) <- vMajor
    for (v in vMajor) {
      vcliq <- coreCliqs[[as.character(v)]]
      for (w in setdiff(vMajor, v)) {
        vcliq <- setdiff(vcliq, coreCliqs[[as.character(w)]])
      }
      if (length(vcliq) > 1) {
        for (i in 1:length(vcliq)) {
          print(sprintf("%d %d - %d - %d", x[1], x[2], v, vcliq[i]))
          sqlQuery(hdbc, sprintf("UPDATE gerry.koalicje SET qualified = 1 WHERE rok = %d AND gmina = %d AND lista1 = %d AND lista2 = %d", x[1], x[2], v, vcliq[i]))
        }
      }
    }
  }
})

sqlQuery(hdbc, "UPDATE gerry.listy AS g
INNER JOIN gerry.koalicje AS k ON g.rok = k.rok AND g.gmina = k.gmina AND g.lista = k.lista2 AND k.qualified = 1
SET g.koalicja = k.lista1;")

sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
INNER JOIN gerry.listy AS lst ON lst.rok = g.rok AND lst.gmina = g.gmina AND lst.lista = g.lista
SET g.koalicja = lst.koalicja WHERE lst.koalicja IS NOT NULL;")

sqlQuery(hdbc, "UPDATE gerry.gerryWybory AS g
INNER JOIN gerry.listy AS lst ON lst.rok = g.rok AND lst.gmina = g.gmina AND lst.lista = g.koalicja
SET g.tag = lst.tag;")
