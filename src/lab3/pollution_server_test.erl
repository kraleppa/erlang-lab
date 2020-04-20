%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. kwi 2020 13:42
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("krzysztof").

-include_lib("eunit/include/eunit.hrl").

start_test() ->
  pollution_server:start(),
  ?assert(lists:member(pollutionServer, registered())).

stop_test() ->
  ?assert(pollution_server:stop() == ok),
  ?assert(not lists:member(pollutionServer, registered())).

addStation_test() ->
  pollution_server:start(),
  ?assertEqual(ok, pollution_server:addStation("Kraków", {20, 20})),
  ?assertEqual(ok, pollution_server:addStation("Czerwone Maki", {21, 20})),
  ?assertMatch({error, _}, pollution_server:addStation("Kraków", {30, 20})),
  ?assertMatch({error, _}, pollution_server:addStation("Lubiąż", {21, 20})).

addValue_test() ->
  ?assertEqual(ok, pollution_server:addValue("Kraków", {2020, 1, 1}, "PM 10", 10)),
  ?assertEqual(ok, pollution_server:addValue({20, 20}, {2020, 1, 2}, "PM 10", 20)),
  ?assertMatch({error, _}, pollution_server:addValue("Kraków", {2020, 1, 1}, "PM 10", 31)).

getOneValue_test() ->
  ?assertEqual(10, pollution_server:getOneValue("Kraków", {2020, 1, 1}, "PM 10")),
  ?assertEqual(10, pollution_server:getOneValue({20, 20}, {2020, 1, 1}, "PM 10")).

getStationMean_test() ->
  ?assertEqual(15.0, pollution_server:getStationMean("Kraków", "PM 10")).





