%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2020 16:18
%%%-------------------------------------------------------------------
-module(parcellockerfinder).
-author("krzysztof").

%% API
-export([randomData/3, findMyParcelLocker/2, start1/2, start2/3]).

randomData(N, Min, Max) -> [{rand:uniform(Max - Min + 1) + Min - 1, rand:uniform(Max - Min + 1) + Min - 1} || _ <- lists:seq(1, N)].

findMyParcelLocker(PersonLocation, LockerLocations) when is_tuple(PersonLocation) and is_list(LockerLocations)->
  CountLength = fun({PX, PY}, {LX, LY}) -> math:sqrt(math:pow(PX - LX, 2) + math:pow(PY - LY, 2)) end,
  DistancesList = [{{X, Y}, CountLength(PersonLocation, {X, Y})} || {X, Y} <- LockerLocations],

  FindMax = fun({{X, Y}, Length}, {_, MLength}) when Length < MLength -> {{X, Y}, Length}; (_, {{MX, MY}, MLength}) -> {{MX, MY}, MLength} end,
  {Result, _} = lists:foldl(FindMax, {{null, null}, inf}, DistancesList),

  Result;

findMyParcelLocker(PeopleLocation, LockerLocations) when is_list(PeopleLocation) and is_list(LockerLocations) ->
  [{{X, Y}, findMyParcelLocker({X, Y}, LockerLocations)} || {X, Y} <- PeopleLocation].


%%----------------------------------------------------------------------------------------------------------------------


findMyParcelLockerParallel(PID, PersonLocation, LockerLocations) when is_pid(PID) and is_tuple(PersonLocation) and is_list(LockerLocations) ->
  Result = findMyParcelLocker(PersonLocation, LockerLocations),
  PID ! {PersonLocation, Result}.

createLoop(_, [], _) -> ok;
createLoop(PID, [Location | PeopleLocations], LockerLocations) ->
  spawn(fun() -> findMyParcelLockerParallel(PID, Location, LockerLocations) end),
  createLoop(PID, PeopleLocations, LockerLocations).

start1(PeopleLocations, LockerLocations) when is_list(PeopleLocations) and is_list(LockerLocations) ->
  PID = spawn(fun() -> server1([], 0, length(PeopleLocations)) end),
  createLoop(PID, PeopleLocations, LockerLocations).

server1(List, Count, Number)->
  receive
    stop -> List;
    Result when is_tuple(Result) ->
      case Count + 1 == Number of
        false -> server1([Result | List], Count + 1, Number);
        true -> io:format("~w ~n", [List])
      end;
    _ -> io:format("Unexpected value")
    after 1000 -> io:format("Timeout exception")
  end.


%%----------------------------------------------------------------------------------------------------------------------
server2(List, Count, Number)->
  receive
    stop -> List;
    Result when is_list(Result) ->
      case Count + 1 == Number of
        false -> server2(List ++ Result, Count + 1, Number);
        true -> io:format("~w ~n",[List ++ Result])
      end;
    _ -> io:format("Unexpected value")
  after 1000 -> io:format("Timeout exception")
  end.

indexList([], _, Result) -> Result;
indexList([H | T], Acc, Result) ->
  indexList(T, Acc + 1, [{H, Acc} | Result]).

findMyParcelLockerParallelMultiple(PID, PeopleLocations, LockerLocations) when is_list(PeopleLocations) and is_list(LockerLocations) ->
  Result = [{{X, Y}, findMyParcelLocker({X, Y}, LockerLocations)} || {X, Y} <- PeopleLocations],
  PID ! Result.


splitLoop(PID, PeopleLocations, LockerLocations, Number, CoresNumber) when Number < CoresNumber ->
  PeopleList = [X || {X, Y} <- PeopleLocations, Y rem CoresNumber == Number],
  spawn(fun() -> findMyParcelLockerParallelMultiple(PID, PeopleList, LockerLocations) end),
  splitLoop(PID, PeopleLocations, LockerLocations, Number + 1, CoresNumber);
splitLoop(_, _, _, _, _) -> ok.


start2(PeopleLocations, LockerLocations, CoresNumber) when is_list(PeopleLocations) and is_list(LockerLocations) ->
  PID = spawn(fun() -> server2([], 0, CoresNumber) end),
  MyPeopleList = indexList(PeopleLocations, 0, []),
  splitLoop(PID, MyPeopleList, LockerLocations, 0, CoresNumber).



