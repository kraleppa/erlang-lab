%%%-------------------------------------------------------------------
%%% @author krzysztof
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2020 15:10
%%%-------------------------------------------------------------------
-module(pingpong).
-author("krzysztof").

%% API
-export([start/0, play/1, stop/0]).

ping(Signals) ->
  receive
    {Pid, A} when A > 0 ->
      io:format("Ping! ~w left. Signals recieved: ~w ~n", [A, Signals]),
      timer:sleep(500),
      Pid ! {self(), A - 1},
      ping(Signals + 1);

    stop -> io:format("Ping has been stopped ~n");

    {Pid, A} when A =< 0 ->
      io:format("Ping ends ~n"),
      Pid ! stop;

    _ -> io:format("Ping unexpected signal ~n")

    after 20000 -> io:format("Ping ends. 20 seconds have passed ~n")
  end.

pong() ->
  receive
    {Pid, A} when A > 0 ->
      io:format("Pong! ~w left ~n", [A]),
      timer:sleep(500),
      Pid ! {self(), A - 1},
      pong();

    stop -> io:format("Pong has been stopped ~n");

    {Pid, A} when A =< 0 ->
      io:format("Pong ends ~n"),
      Pid ! stop;

    _ -> io:format("Pong unexpected signal ~n")

    after 20000 -> io:format("The end. 20 seconds passed ~n")
  end.

start() ->
  register(ping, spawn(fun() -> ping(0) end)),
  register(pong, spawn(fun() -> pong() end)).

stop() ->
  ping ! stop,
  pong ! stop.

play(N) -> ping ! {pong, N}.