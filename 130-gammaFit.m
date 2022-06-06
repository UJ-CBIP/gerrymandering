alpha14a = (#[[4]]) & /@ Select[(#[[1]] == "2014") &][SQLSelect[conn, "gerry.distribDirV_okr"]]

alpha14 = (#[[4]]) & /@ Select[(#[[1]] == "2014") &][SQLSelect[conn, "gerry.distribDirP"]]

CompoundDensity[x_, n_, a_, k_, \[Theta]_, Precision_: Automatic] := 
 NIntegrate[
  x^(\[Alpha]*p - 1) * (1 - x)^(\[Alpha]*(1 - p) - 1) * 
   p^(a - 1) * (1 - p)^(n*a - a - 1) * \[Alpha]^(k - 1) * 
   Exp[-\[Alpha]/\[Theta]] / (Gamma[k] * \[Theta]^k * 
      Beta[a, (n - 1)*a]*Beta[p*\[Alpha], (1 - p)*\[Alpha]]), {p, 0, 
   1}, {\[Alpha], 0, Infinity}, PrecisionGoal -> Precision]

VDensity[x_, n_, \[Alpha]0_] :=  PDF[BetaDistribution[\[Alpha]0, (n - 1)*\[Alpha]0], x]

TVDist[n_, a_, k_, \[Theta]_, \[Alpha]0_, Precision_: Automatic] := 
 NIntegrate[
  Abs[CompoundDensity[x, n, a, k, \[Theta], Precision] - 
    VDensity[x, n, \[Alpha]0]], {x, 0.01, 0.99}, 
  PrecisionGoal -> Precision]

NMinimize[{TVDist[2, alpha14[[2]], k, \[Theta], alpha14a[[2]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{131.7592, 0.0924516}}}]

NMinimize[{TVDist[3, alpha14[[3]], k, \[Theta], alpha14a[[3]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{30.9307, 0.42139}}}]

NMinimize[{TVDist[4, alpha14[[4]], k, \[Theta], alpha14a[[4]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{37.1382, 0.400281}}}]

NMinimize[{TVDist[5, alpha14[[5]], k, \[Theta], alpha14a[[5]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{23.9234, 0.778475}}}]

NMinimize[{TVDist[6, alpha14[[6]], k, \[Theta], alpha14a[[6]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{51.1434, 0.413013}}}]

NMinimize[{TVDist[7, alpha14[[7]], k, \[Theta], alpha14a[[7]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{49.1887, 0.473778}}}]

NMinimize[{TVDist[8, alpha14[[8]], k, \[Theta], alpha14a[[8]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{95.6092, 0.287002}}}]

NMinimize[{TVDist[9, alpha14[[9]], k, \[Theta], alpha14a[[9]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{102.528, 0.41032}}}]

NMinimize[{TVDist[10, alpha14[[10]], k, \[Theta], alpha14a[[10]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{72.774, 0.422984}}}]

NMinimize[{TVDist[11, alpha14[[11]], k, \[Theta], alpha14a[[11]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{86.106, 0.492375}}}]

NMinimize[{TVDist[12, alpha14[[12]], k, \[Theta], alpha14a[[12]], 3], 
  k > 0, \[Theta] > 0}, {k, \[Theta]}, 
 EvaluationMonitor :> Print["k = ", k, ", \[Theta] =", \[Theta]], 
 Method -> {"NelderMead", "InitialPoints" -> {{61.8211, 0.897618}}}]

(* plots *)