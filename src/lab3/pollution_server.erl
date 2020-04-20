%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. kwi 2020 16:15
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("krzysztof").

%% API
-export([start/0, init/0, stop/0, showMonitor/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDailyOverLimit/3, getYearlyMean/2]).
-import(pollution, [createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDailyOverLimit/4, getYearlyMean/3, getStationByCords/2]).

start() -> register(pollutionServer, spawn(pollution_server, init, [])).
init() -> loop(createMonitor()).
stop() -> call({stop, self()}).
showMonitor() -> call({show, self()}).

call(Message) ->
  pollutionServer ! Message,
  receive
    {reply, Reply} -> Reply;
    _ -> {error, "Response error"}
  after 5000 -> {error, "Connection Error"}
  end.

loop(Monitor) ->
  receive
    {addStation, PID, {Name, Cords}} -> PID ! {reply, ok}, loop(addStation(Name, Cords, Monitor));
    {addValue, PID, {Station, Date, Type, Value}} -> PID ! {reply, ok}, loop(addValue(Station, Date, Type, Value, Monitor));
    {show, PID} -> PID ! {reply, Monitor}, loop(Monitor);
    {removeValue, PID, {Station, Date, Type}} -> PID ! {reply, ok}, loop(removeValue(Station, Date, Type, Monitor));
    {getOneValue, PID, {Station, Date, Type}} -> PID ! {reply, getOneValue(Station, Date, Type, Monitor)}, loop(Monitor);
    {getStationMean, PID, {Station, Type}} -> PID !  {reply, getStationMean(Station, Type, Monitor)}, loop(Monitor);
    {getDailyMean, PID, {Type, Date}} -> PID ! {reply, getDailyMean(Type, Date, Monitor)}, loop(Monitor);
    {getDailyOverLimit, PID, {Type, Date, Limit}} -> PID ! {reply, getDailyOverLimit(Type, Date, Limit, Monitor)}, loop(Monitor);
    {getYearlyMean, PID, {Type, Year}} -> PID ! {reply, getYearlyMean(Type, Year, Monitor)}, loop(Monitor);
    {stop, PID} -> PID ! {reply, ok};
    _ -> loop(Monitor)
  end.


addStation(Name, Cords) -> call({addStation, self(), {Name, Cords}}).
addValue(Station, Date, Type, Value) -> call({addValue, self(), {Station, Date, Type, Value}}).
removeValue(Station, Date, Type) -> call({removeValue, self(), {Station, Date, Type}}).
getOneValue(Station, Date, Type) -> call({getOneValue, self(), {Station, Date, Type}}).
getStationMean(Station, Type) -> call({getStationMean, self(), {Station, Type}}).
getDailyMean(Type, Date) -> call({getDailyMean, self(), {Type, Date}}).
getDailyOverLimit(Type, Date, Limit) -> call({getDailyOverLimit, self(), {Type, Date, Limit}}).
getYearlyMean(Type, Year) -> call({getYearlyMean, self(), {Type, Year}}).


