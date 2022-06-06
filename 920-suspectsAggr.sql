SELECT rok, gmina, nazwa, psi, eta, H,
    CASE
        WHEN psi <= eta AND psi <= H THEN psi
        WHEN psi > eta AND psi <= H THEN (X*psi + eta) / (X+1)
        WHEN psi > H AND psi <= eta THEN (X*psi + H) / (X+1)
        WHEN psi > H AND psi > eta THEN (X*psi + H + eta) / (X+2)
    END AS gerry
FROM (
    SELECT rok, gmina, nazwa, 5 AS X,
        (svDirichlet_ecdf + svKernel_ecdf + svOutlier_ecdf + IFNULL(biasL1_ecdf, 0) + IFNULL(effGap_ecdf, 0)) /
            (3 + IF(ISNULL(biasL1_ecdf), 0, 1) + IF(ISNULL(effGap_ecdf), 0, 1)) AS psi,
        IFNULL(monotonic_ecdf, 1) AS eta, IFNULL(malTurnout_ecdf, 1) AS H
    FROM gerry.suspects WHERE rok = 2014 ORDER BY psi ASC
) AS x ORDER BY gerry ASC