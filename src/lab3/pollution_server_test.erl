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

addStation_test() ->
  ?assertEqual(ok, pollution_server:addStation("Kraków", {20, 20})),
  ?assertEqual(ok, pollution_server:addStation("Czerwone Maki", {21, 20})),

  ?assertMatch({error, _}, pollution_server:addStation("Kraków", {30, 20})),
  ?assertMatch({error, _}, pollution_server:addStation("Chrząszczyżewoszyce", {21, 20})).

addValue_test() ->
  ?assertEqual(ok, pollution_server:addValue("Kraków", {2020, 1, 1}, "PM 10", 10)),
  ?assertEqual(ok, pollution_server:addValue({20, 20}, {2020, 1, 2}, "PM 10", 20)),

  ?assertMatch({error, _}, pollution_server:addValue("Kraków", {2020, 1, 1}, "PM 10", 31)).

getOneValue_test() ->
  ?assertEqual(10, pollution_server:getOneValue("Kraków", {2020, 1, 1}, "PM 10")),
  ?assertEqual(10, pollution_server:getOneValue({20, 20}, {2020, 1, 1}, "PM 10")),
  ?assertMatch({error, _}, pollution_server:getOneValue("Łękołody", {2020, 1, 1}, "PM 10")).

removeValue_test() ->
  pollution_server:addValue("Kraków", {2020, 07, 07}, "PM 2.5", 10),
  ?assertMatch(ok, pollution_server:removeValue("Kraków", {2020, 07, 07}, "PM 2.5")),
  ?assertMatch({error, _}, pollution_server:removeValue("Kraków", {2020, 07, 07}, "PM 2.5")).


getStationMean_test() ->
  ?assertEqual(15.0, pollution_server:getStationMean("Kraków", "PM 10")),
  ?assertMatch({error, _}, pollution_server:getStationMean("Szczebrzeszyn", "PM 10")).

getDailyMean_test() ->
  pollution_server:addValue("Czerwone Maki", {2020, 1, 1}, "PM 10", 50),
  ?assertEqual(30.0, pollution_server:getDailyMean("PM 10", {2020, 1, 1})),
  ?assertMatch({error, _}, pollution_server:getDailyMean("PM 10", {2020, 312321, 373})).

getDailyOverLimit_test() ->
  ?assertEqual(0, pollution_server:getDailyOverLimit("PM 10", {2020, 1, 1}, 100)),
  ?assertEqual(1, pollution_server:getDailyOverLimit("PM 10", {2020, 1, 1}, 49)),
  ?assertEqual(2, pollution_server:getDailyOverLimit("PM 10", {2020, 1, 1}, 9)),
  ?assertMatch({error, _}, pollution_server:getDailyOverLimit("PM 10", {2020, 9921, 3799}, 9)).

getYearlyMean_test() ->
  pollution_server:addValue("Czerwone Maki", {2020, 2, 1}, "PM 10", 10),
  ?assertEqual(22.5, pollution_server:getYearlyMean("PM 10", 2020)).

stop_test() ->
  ?assert(pollution_server:stop() == ok),
  ?assert(not lists:member(pollutionServer, registered())).









