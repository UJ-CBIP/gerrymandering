Needs["DatabaseLink`"]
conn = OpenSQLConnection["cbip"];
data = SQLSelect[conn, "gerry.gerryWybory", {"rok", "gmina", "okreg", "lista", "listOkr", "expect", "k", "theta"}, (SQLColumn["listOkr"] > 1) && (SQLColumn["expect"] > 0)&& (SQLColumn["rok"] == "2018")];
data2 = GroupBy[data, ((<|"rok" -> #[[1]], "gmina" -> #[[2]], "okreg" -> #[[3]], "n" -> #[[5]], "k" -> #[[7]], "theta" -> #[[8]]|>) &) -> ((<|#[[4]] -> #[[6]]|>) &)];

ExpectSeats = Function[{list, i, alpha}, Gamma[alpha*First@Part[list, i]] / Times @@ Flatten[Gamma /@ (list*alpha)] * NIntegrate[(Times @@ Flatten[(Gamma[alpha*#, 0, x]) & /@ Delete[list, i]]) * PDF[GammaDistribution[alpha*First@Part[list, i], 1], x], {x, 0, Infinity}, WorkingPrecision -> MachinePrecision, AccuracyGoal -> 4]];

ExpectSeatsEx = Function[{list, i, k, \[Theta]}, NIntegrate[ExpectSeats[list, i, alpha] * PDF[GammaDistribution[k, \[Theta]], alpha], {alpha, 0, Infinity}, WorkingPrecision -> MachinePrecision]];

ExpectSeatsVec[list_, k_, \[Theta]_] := AssociationThread[(Flatten@Keys[list]) -> Table[Catch[ExpectSeatsEx[Evaluate[Values[list]], i, k, \[Theta]], _SystemException], {i, Length[list]}]]

ExpectSeatsDistrict[data_, j_] := ExpectSeatsVec[Values[data][[j]], Keys[data][[j]][["k"]], Keys[data][[j]][["theta"]]]

expSeats = Monitor[Table[ExpectSeatsDistrict[data2, j], {j, Length[data2]}], Row[{ProgressIndicator[j, {1, Length[data2]}], {j, i, Keys[data2][[j]]}}, " "]]

Export["seats.csv", Flatten[MapIndexed[Function[{value, idx}, KeyValueMap[(List[Keys[data2][[First[idx]]]["rok"], Keys[data2][[First[idx]]]["gmina"], Keys[data2][[First[idx]]]["okreg"], #1, #2]) &, value]]][expSeats], 1], "CSV"];
