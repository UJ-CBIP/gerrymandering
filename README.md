# List of files
## Database setup
* [`000-gerryWybory.sql`](000-gerryWybory.sql) -- generates the district-level candidate results table (`gerryWybory`) -- first main data table used in computations
* [`005-compECDF.R`](005-compECDF.R) -- computes empirical CDFs for candidate votes
* [`010-gerryListy.sql`](010-gerryListy.sql) -- generates the aggregate electoral list results table (`gerryListy`)
* [`020-gerryKoalicje.sql`](020-gerryKoalicje.sql) -- generates the potential functional coalitions table (`gerryKoalicje`)
* [`025-koalicje.R`](025-koalicje.R) -- the algorithm for detecting functional coalitions
* [`030-gerryGminyAux.sql`](030-gerryGminyAux.sql) -- generates the per-township aggregate stats table (`gminy`)
* [`040-gerryAggr.sql`](040-gerryAggr.sql) -- generates the aggregate party results table (`gerry`) -- second main data table used in computations
* [`050-gerryWybPostProcess.sql`](050-gerryWybPostProcess.sql) -- post-processing of `gerryWybory` table -- computes means, effective numbers of competitors, etc.
* [`060-gerryRank.sql`](060-gerryRank.sql) -- post-processing of `gerry` table -- computes rankings
* [`070-gerryGminyAuxPostproc.sql`](070-gerryGminyAuxPostproc.sql) -- post-processing of `gminy` table - computes winners, runner-ups, and effective numbers of coalitions
* [`080-gerryHypoSV.sql`](080-gerryHypoSV.sql) -- generates the vote-shifted results tables (`gerryHypoWybory` and `gerryHypoSV`)
* [`090-gerryOkregi.sql`](090-gerryOkregi.sql) -- generates the district-level aggregate stats table (`gerryOkregi`)

## Chapter 3.2 -- seats-votes
* [`100-anonAlphaFit.R`](100-anonAlphaFit.R) -- R code for fitting $\alpha$ parameters
* [`110-qFit.R`](110-qFit.R) -- R code for fitting $q$ parameters
* [`115-qFitHypo.R`](115-qFitHypo.R) -- R code for fitting $q$ parameters for vote-shifted results tables
* [`210-qFit.R`](120-qFit.R) -- R code for fitting $p$ parameters
* [`130-gammaFit.m`](130-gammaFit.m) -- Mathematica code for fitting the $p$ parameter distribution
* [`135-gammaFitUpdate.sql`](135-gammaFitUpdate.sql) -- SQL script that saves the results of `130-gammaFit.m` to the database
* [`150-expSeats.m`](150-expSeats.m) -- Mathematica code for computing seat expectations
* [`155-expSeatsUpdate.sql`](155-expSeatsUpdate.sql) -- SQL script that saves the results of `150-expSeats.m` to the database
* [`160-seatsDist.R`](160-seatsDist.R) -- R code for computing seat count distributions
* [`165-pValues.sql`](165-pValues.sql) -- SQL code for computing empirical seat $p$-values

* [`200-effThold.R`](200-effThold.R) -- compute effective seat thresholds
* [`250-np.R`](250-np.R) -- compute non-parameteric seats-votes regression curve

* [`300-normalizeV.R`](300-normalizeV.R) -- compute normalized vote percentages
* [`350-outliers.sql`](350-outliers.sql) -- compute outlier detection scores
* [`360-outliersNorm.sql`](360-outliersNorm.sql) -- normalize outlier detection scores

* [`chapter-3-2.sql`](chapter-3-2.sql) -- generate tables for Chapter 3.2
* [`chapter-3-2-plots.R`](chapter-3-2-plots.R) -- generate plots for Chapter 3.2

## Chapter 3.3 -- partisan bias
* [`400-partisanBias.R`](400-partisanBias.R) -- compute requisite vote swings
* [`405-gerrySwing.sql`](405-gerrySwing.sql) -- initialize vote swing simulation tables
* [`410-gerrySwingV.R`](410-gerrySwingV.R) -- vote swing simulations
* [`420-uniformSwing.R`](420-uniformSwing.R) -- uniform swing simulations (old version)

* [`chapter-3-3.R`](chapter-3-3.R) -- generate tables for Chapter 3.3
* [`chapter-3-3-plots.R`](chapter-3-3-plots.R) -- generate plots for Chapter 3.3

## Chapter 3.4 -- efficiency gap
* [`500-wastedVotes.sql`](500-wastedVotes.sql) -- compute wasted vote counts
* [`550-efficiencyGap.R`](550-efficiencyGap.R) -- compute efficiency gap indices

* [`chapter-3-4.sql`](chapter-3-4.sql) -- generate tables for Chapter 3.4

## Chapter 3.5 -- malapportionment
* [`600-malapp.sql`](600-malapp.sql) -- compute malapportionment indices
* [`650-malappParty.sql`](650-malappParty.sql) -- compute party-specific malapportionment indices

* [`chapter-3-5.sql`](chapter-3-5.sql) -- generate tables for Chapter 3.5
* [`chapter-3-5.R`](chapter-3-5.R) -- statistical model for Chapter 3.5

## Chapter 3.7 -- circumstantial evidence
* [`700-monotonicity.sql`](700-monotonicity.sql) -- compute non-monotonicity index
* [`720-incumPacking.sql`](720-incumPacking.sql) -- compute incumbency packing index
* [`740-polarWBP.sql`](740-polarWBP.sql) -- compute mayoral polarization index
* [`750-tiltClusWBP.R`](750-tiltClusWBP.R) -- precinct clustering for tilt computations
* [`760-tiltWBP.sql`](760-tiltWBP.sql) -- compute mayoral election tilt
* [`770-tiltRDA.sql`](770-tiltRDA.sql) -- compute council election tilt

* [`chapter-3-7-polar.sql`](chapter-3-7-polar.sql) -- generate tables for Chapter 3.7
* [`chapter-3-7-polar.R`](chapter-3-7-polar.R) -- generate plots for Chapter 3.7

## Chapter 3.8 -- gerrymandering in Krakow

* [`krakow.sql`](krakow.sql) -- generate tables
* [`krakow0.sql`](krakow0.sql) -- generate tables
* [`krakow1-thold.R`](krakow1-thold.R) -- compute effective seat thresholds
* [`krakow2-q.R`](krakow2-q.R) -- estimate $q$ parameters
* [`krakow3-p.R`](krakow3-p.R) -- estimate $p$ parameters
* [`krakow2-expectS.sql`](krakow2-expectS.sql) -- compute expected seats
* [`krakow2-sDist.R`](krakow2-sDist.R) -- compute seat distributions
* [`krakow2-pValues.sql`](krakow2-pValues.sql) -- compute $p$-values
* [`krakow4-np.R`](krakow4-np.R) -- compute non-parametric seats-votes curves
* [`krakow5-norm.R`](krakow5-norm.R) -- compute normalized votes
* [`krakow6-outliers.sql`](krakow6-outliers.sql) -- identify outliers
* [`krakow7-swing.R`](krakow7-swing.R) -- swing simulations
* [`krakow7-swing2.R`](krakow7-swing2.R) -- swing simulations
* [`krakow8-waste.sql`](krakow8-waste.sql) -- compute wasted votes

* [`krakowStats.sql`](krakowStats.sql) -- aggregate stats
* [`chapter-3-8-wyniki.R`](chapter-3-8-wyniki.R) -- generate election result plots for Chapter 3.8
* [`chapter-3-8.R`](chapter-3-8.R) -- generate method plots for Chapter 3.8

## Chapter 4.1 -- suspect identification
* [`900-suspects.sql`](900-suspects.sql) -- generates the `suspects` table
* [`920-suspectsAggr.sql`](920-suspectsAggr.sql) -- aggregation of suspicion indices
* [`950-intent.sql`](950-intent.sql) -- aggregation of intent indicators

* [`chapter-4-1.sql`](chapter-4-1.sql) -- generate tables for Chapter 4.1
* [`chapter-4-1.R`](chapter-4-1.R) -- generate plots for Chapter 4.1
* [`chapter-4-5.sql`](chapter-4-5.sql) -- generate tables for Chapter 4.5
* [`chapter-4-5.R`](chapter-4-5.R) -- generate plots for Chapter 4.5

# Credits
Author: [Dariusz Stolicki](https://cbip.uj.edu.pl/stolicki)

Jagiellonian Center for Quantitative Political Science, Jagiellonian University, Krakow, Poland

Copyright (C) Jagiellonian University 2016-2022

Supported under NCN grant no. 2014/13/B/HS5/00862
