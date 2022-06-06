hdbc <- odbcConnect("cbip", case="nochange")
s18 <- sqlQuery(hdbc, "SELECT s14.gmina, s14.nazwa, s14.value AS psi14, s18.value AS psi18, s14.rank AS rnk14, s18.rank AS rnk18,
    s14.ecdf AS norm14, s18.ecdf AS norm18
FROM gerry.gerrySuspects AS s14
INNER JOIN gerry.gerrySuspects AS s18 ON s18.rok = 2018 AND s18.gmina = s14.gmina AND s18.indicator = s14.indicator
WHERE s14.rok = 2014 AND s14.indicator = 'Psi'
ORDER BY s14.`rank` ASC;")