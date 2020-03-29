%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. mar 2020 15:46
%%%-------------------------------------------------------------------
-module(pollution).
-author("krzysztof").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3]).

-record(monitor, {stations, data}).

createMonitor() -> #monitor{stations = #{}, data = #{}}.


stationExists(Name, Monitor) ->
  Map = maps:filter(fun(Station, _) -> Station == Name end, Monitor#monitor.stations),
  maps:size(Map) /= 0.


addStation(Name, {X, Y}, Monitor) when is_list(Name) and is_number(X) and is_number(Y) and is_record(Monitor, monitor)->
  case stationExists(Name, Monitor) of
    false -> #monitor{stations = maps:put(Name, {X, Y}, Monitor#monitor.stations), data = Monitor#monitor.data};
    _ -> Monitor
  end.


valueExists(Tuple, Monitor) ->
  Map = maps:filter(fun(Key, _) -> Key == Tuple end, Monitor#monitor.data),
  maps:size(Map) /= 0.


addValue(Name, Date, Type, Value, Monitor) when is_list(Name) and is_list(Type) and is_number(Value) and is_record(Monitor, monitor)->
  case calendar:valid_date(Date) and not valueExists({Name, Date, Type}, Monitor) of
    true -> #monitor{stations = Monitor#monitor.stations, data = maps:put({Name, Date, Type}, Value, Monitor#monitor.data)};
    _ -> Monitor
  end.


removeValue(Name, Date, Type, Monitor) when is_list(Name) and is_list(Type) and is_record(Monitor, monitor) ->
  #monitor{stations = (Monitor#monitor.stations), data = maps:remove({Name, Date, Type}, Monitor#monitor.data)}.


getOneValue(Name, Date, Type, Monitor) when is_list(Name) and is_list(Type) and is_record(Monitor, monitor) ->
  case valueExists({Name, Date, Type}, Monitor) of
    true -> maps:get({Name, Date, Type}, Monitor#monitor.data);
    _ -> null
  end.

getStationMean(Name, Type, Monitor) when is_list(Name) and is_list(Type) ->
  F = fun({KeyName, _, KeyType}, _) -> (Name == KeyName) and (Type == KeyType) end,
  Map = maps:filter(F, (Monitor#monitor.data)),
  Sum = maps:fold(fun(_, Value, Acc) -> Acc + Value end, 0, Map),
  Sum / maps:size(Map).


getDailyMean(Type, Date, Monitor) when is_list(Type) ->
  case calendar:valid_date(Date) of
    true ->
      Map = maps:filter(fun({_, KeyDate, KeyType}, _) -> (Date == KeyDate) and (Type == KeyType) end, Monitor#monitor.data),
      Sum = maps:fold(fun(_, Value, Acc) -> Acc + Value end, 0, Map),
      Sum / maps:size(Map);
    false -> null
  end.

