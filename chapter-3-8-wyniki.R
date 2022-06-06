hdbc <- odbcConnect("cbip", case="nochange")
krkdf <- sqlQuery(hdbc, "SELECT * FROM gerry.krakow")
normalize <- function(x) x / sum(x)

krkdf0 <- filter(krkdf) %>% group_by(id, okreg) %>%
  summarize(upraw = sum(upraw), glos = sum(glos), pisPct = sum(pis) / sum(pis + po), poPct = sum(po) / sum(pis + po), .groups = "drop_last") %>%
  mutate(upraw = normalize(upraw) * 43) %>% mutate(glos = normalize(glos) * 43) %>%
  mutate(pis = pisPct, po = poPct)

plot1 <- ggplot(
  filter(krkdf0, id == 126100) %>% arrange(desc(po)) %>% mutate(okreg = row_number())
    %>% pivot_longer(pis:po, names_to = "partia", values_to = "v")) +
  geom_col(aes(x = okreg, y = v, fill = partia), position = "fill") +
  xlab("k") + theme(axis.title.y = element_blank()) + scale_y_continuous(position = "right") +
  geom_hline(aes(yintercept = 0.5), lwd=1) +
  scale_fill_manual(values = c("orange", "blue"), breaks = c("po", "pis"))
plot2 <- ggplot(
  filter(krkdf0, id == 126300) %>% arrange(desc(pis)) %>% mutate(okreg = row_number())
    %>% pivot_longer(pis:po, names_to = "partia", values_to = "v")) +
  geom_col(aes(x = okreg, y = v, fill = partia), position = "fill") +
  xlab("k") + ylab(expression(v)) + theme(axis.title.y = element_text(angle = 0, vjust = 0.6)) +
  geom_hline(aes(yintercept = 0.5), lwd=1) +
  scale_fill_manual(values = c("orange", "blue"), breaks = c("po", "pis"))
ggarrange(plot1, plot2, common.legend = TRUE)

krkdf1 <- filter(krkdf) %>% group_by(id, okreg) %>%
  summarize(upraw = sum(upraw), glos = sum(glos), pisPct = sum(pis) / sum(glos), poPct = sum(po) / sum(glos), .groups = "drop_last") %>%
  mutate(upraw = normalize(upraw) * 43) %>% mutate(glos = normalize(glos) * 43) %>%
  mutate(pis = pisPct, po = poPct)

plot1 <- ggplot(
  filter(krkdf1, id == 126100) %>% arrange(desc(po)) %>% mutate(okreg = row_number())
  %>% pivot_longer(pis:po, names_to = "partia", values_to = "v")) +
  geom_col(aes(x = okreg, y = v, fill = partia), position = "stack") +
  xlab("k") + theme(axis.title.y = element_blank()) + scale_y_continuous(position = "right", limits=c(0, 0.75)) +
  scale_fill_manual(values = c("orange", "blue"), breaks = c("po", "pis")) +
  theme(legend.position = "none")
plot2 <- ggplot(
  filter(krkdf1, id == 126300) %>% arrange(desc(pis)) %>% mutate(okreg = row_number())
  %>% pivot_longer(pis:po, names_to = "partia", values_to = "v")) +
  geom_col(aes(x = okreg, y = v, fill = partia), position = position_stack(reverse = TRUE)) +
  xlab("k") + ylab(expression(v)) + theme(axis.title.y = element_text(angle = 0, vjust = 0.6)) +
  scale_y_continuous(position = "left", limits=c(0, 0.75)) +
  scale_fill_manual(values = c("orange", "blue"), breaks = c("po", "pis")) +
  theme(legend.position = "none")
ggarrange(plot1, plot2)

plot1 <- ggplot(
  filter(krkdf0, id == 126100) %>% arrange(desc(upraw)) %>% mutate(okreg = row_number())) +
  geom_col(aes(x = okreg, y = upraw), fill = "navy") +
  xlab("k") + theme(axis.title.y = element_blank()) + scale_y_continuous(position = "right") +
  geom_hline(aes(yintercept = 1), lwd=1)
plot2 <- ggplot(
  filter(krkdf0, id == 126100) %>% arrange(desc(glos)) %>% mutate(okreg = row_number())) +
  geom_col(aes(x = okreg, y = glos), fill = "navy") +
  xlab("k") + ylab(expression(w)) + theme(axis.title.y = element_text(angle = 0, vjust = 0.5)) +
  geom_hline(aes(yintercept = 1), lwd=1)
plot3 <- ggplot(
  filter(krkdf0, id == 126300) %>% arrange(desc(upraw)) %>% mutate(okreg = row_number())) +
  geom_col(aes(x = okreg, y = upraw), fill = "navy") +
  xlab("k") + theme(axis.title.y = element_blank()) + scale_y_continuous(position = "right") +
  geom_hline(aes(yintercept = 1), lwd=1)
plot4 <- ggplot(
  filter(krkdf0, id == 126300) %>% arrange(desc(glos)) %>% mutate(okreg = row_number())) +
  geom_col(aes(x = okreg, y = glos), fill = "navy") +
  xlab("k") + ylab(expression(w)) + theme(axis.title.y = element_text(angle = 0, vjust = 0.5)) +
  geom_hline(aes(yintercept = 1), lwd=1)
ggarrange(plot1, plot2, plot3, plot4, ncol = 2, nrow = 2)

o10to14 <- sqlQuery(hdbc, "SELECT oo.obw2014, oo.obw2010, o10.upraw, o10.pis / (o10.pis + o10.po) AS pis10, o14.pis14 / (o14.pis14 + o14.po14) AS pis14
FROM (
SELECT obw2014, obw2010, upraw, ROUND(pis + delta) AS pis, ROUND(IF(po >= delta, po - delta, po / 2)) AS po FROM (
    SELECT o.obw2010, o.obw2014, IFNULL(SUM(obw.pop14), 0) AS upraw, IF(o.obw2014 > 0, pis.glos, 0) AS pis,
        IF(o.obw2014 > 0, po.glos, 0) AS po, IF(o.obw2014 > 0, jm.glos, 0) AS jm, IF(o.obw2014 > 0, sld.glos, 0) AS sld,
        IF(o.obw2014 > 0, kor.glos, 0) AS korwin, 0 AS gibala,
        IF(o.obw2014 > 0, f.glosW - pis.glos - po.glos - jm.glos - sld.glos - kor.glos, 0) AS inni,
        IF(o.obw2014 > 0, f.glosW / SUM(f.glosW) OVER () * 18830, 0) AS delta
    FROM gerry.krakowObw10to14 AS o
    INNER JOIN wybory.frekwAgrWide AS f ON f.akcja = '20101121/000000/SMD' AND f.organ = 'RDA' AND f.turaPytanie = 1 AND f.poziom = 'OBW' AND
        f.terytAgr = 126101 AND f.subAgr = o.obw2010
    LEFT JOIN gerry.krakowObwody AS obw ON obw.obwod = o.obw2014
    INNER JOIN gerry.krakowObw10 AS pis ON pis.obwod = o.obw2010 AND pis.lista = 5
    INNER JOIN gerry.krakowObw10 AS po ON po.obwod = o.obw2010 AND po.lista = 4
    INNER JOIN gerry.krakowObw10 AS sld ON sld.obwod = o.obw2010 AND sld.lista = 1
    INNER JOIN gerry.krakowObw10 AS jm ON jm.obwod = o.obw2010 AND jm.lista = 17
    INNER JOIN gerry.krakowObw10 AS kor ON kor.obwod = o.obw2010 AND kor.lista = 21
    GROUP BY o.obw2010, o.obw2014
) AS x
) AS o10 INNER JOIN gerry.krakowObw10to14 AS oo ON oo.obw2010 = o10.obw2010 AND oo.obw2014 = o10.obw2014
INNER JOIN gerry.krakowObwody AS o14 ON o14.obwod = oo.obw2014
WHERE o14.zamkniety = 0;")