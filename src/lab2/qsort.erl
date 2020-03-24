%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. mar 2020 19:10
%%%-------------------------------------------------------------------
-module(qsort).
-author("krzysztof").

%% API
-export([qs/1, randomElements/3, compareSpeeds/3]).

lessThan(List, Arg) -> [X || X <- List, X < Arg].

greaterEqThan(List, Arg) -> [X || X <- List, X >= Arg].

qs([Pivot | Tail]) -> qs(lessThan(Tail, Pivot)) ++ [Pivot] ++ qs(greaterEqThan(Tail, Pivot));
qs([]) -> [].

randomElements(N, Min, Max) -> [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

compareSpeeds(List, Fun1, Fun2) ->
  {T1, _} = timer:tc(Fun1, [List]),
  {T2, _} = timer:tc(Fun2, [List]),
  io:format("Function1: ~p ms ~nFunction2: ~p ms~n", [T1, T2]),
  {T1, T2}.
