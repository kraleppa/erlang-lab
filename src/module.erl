%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. mar 2020 20:54
%%%-------------------------------------------------------------------
-module(module).
-author("krzysztof").

%% API
-export([power/2]).

power(_, 0) -> 1;
power(X, Y) when Y > 0 -> X * power(X, Y - 1);
power(X, Y) when Y < 0 -> 1 / X * power(X, Y + 1).
