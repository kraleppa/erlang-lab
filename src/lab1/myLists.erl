%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. mar 2020 20:57
%%%-------------------------------------------------------------------
-module(myLists).
-author("krzysztof").

%% API
-export([contains/2, duplicateElements/1, sumFloats/1, sumFloatsTail/2]).

contains([], _) -> false;
contains([H | _], H) -> true;
contains([_ | T], V) -> contains(T, V).

duplicateElements([]) -> [];
duplicateElements([H | []]) -> [H, H];
duplicateElements([H | T]) -> [H, H | duplicateElements(T)].

sumFloats([]) -> 0.0;
sumFloats([H | T]) when is_float(H) -> H + sumFloats(T);
sumFloats([_ | T]) -> sumFloats(T).

sumFloatsTail([], Sum) -> Sum;
sumFloatsTail([H | T], Sum) when is_float(H) -> sumFloatsTail(T, Sum + H);
sumFloatsTail([_ | T], Sum) -> sumFloatsTail(T, Sum).