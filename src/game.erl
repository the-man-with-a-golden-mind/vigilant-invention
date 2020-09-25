-module (game).
-compile(export_all).
% -export([run/0, board_search_possible_moves/3, new_board/0,

% 		 go_right/4, get_random_move/1, board_set/4, is_board_empty/3]).

-record (player, {x, y}).
-record (ggame, {player, board, max_board, max_score, score, iterations, startTime, endTime}).

-define(LR, 3).
-define(DIAG, 2).
-define(SIZE, 10).

new_board() -> 
	list_to_tuple([list_to_tuple([0 || _<- lists:seq(1,?SIZE)]) || _ <- lists:seq(1, ?SIZE)]).

new_game(MAXBOARD, MAXSCORE, ITERATIONS) ->
	NEWPLAYER = #player{x=rand:uniform(?SIZE), y=rand:uniform(?SIZE)},
	NEWBOARD = new_board(),
	#ggame{player=NEWPLAYER, board=NEWBOARD, max_board=MAXBOARD, max_score=MAXSCORE, 
		   score=0, iterations=ITERATIONS, startTime=erlang:system_time(), endTime=0}.


board_get(X, Y, BOARD) ->
	element(X, element(Y, BOARD)).

board_set(X, Y, NUMBER, BOARD) ->
	ROW = element(Y, BOARD),
	NEWROW = setelement(X, ROW, NUMBER),
	setelement(Y, BOARD, NEWROW).

is_board_empty(X, Y, BOARD) ->
	element(X, element(Y, BOARD)) == 0.

go_right(MOVES, X, Y, BOARD) when (X + ?LR =< ?SIZE), (Y =< ?SIZE) ->
	case is_board_empty(X + ?LR ,Y,BOARD) of
		true -> 
			erlang:append_element(MOVES, {X + ?LR, Y});
		false ->
			MOVES
	end;
go_right(MOVES, _, _, _) ->
	MOVES.

go_left(MOVES, X, Y, BOARD) when (X - ?LR >= 1), (Y =< ?SIZE) ->
	case is_board_empty(X - ?LR,Y,BOARD) of
		true -> 
			erlang:append_element(MOVES, {X - ?LR, Y});
		false ->
			MOVES
	end;
go_left(MOVES, _, _, _) ->
	MOVES.

go_up(MOVES, X, Y, BOARD) when (X =< ?SIZE), (Y - ?LR >= 1) ->
	case is_board_empty(X,Y - ?LR,BOARD)of
		true -> 
			erlang:append_element(MOVES, {X, Y - ?LR});
		false ->
			MOVES
	end;
go_up(MOVES, _, _, _) ->
	MOVES.

go_down(MOVES, X, Y, BOARD) when (X =< ?SIZE), (Y + ?LR =< ?SIZE) ->
	case is_board_empty(X, Y + ?LR, BOARD) of
		true -> 
			erlang:append_element(MOVES, {X, Y + ?LR});
		false ->
			MOVES
	end;
go_down(MOVES, _, _, _) ->
	MOVES.

go_up_left(MOVES, X, Y, BOARD) when (X - ?DIAG >= 1), (Y - ?DIAG  >= 1) ->
	case is_board_empty(X - ?DIAG , Y - ?DIAG ,BOARD) of
		true -> 
			erlang:append_element(MOVES, {X - ?DIAG, Y - ?DIAG});
		false ->
			MOVES
	end;
go_up_left(MOVES, _, _, _) ->
	MOVES.

go_up_right(MOVES, X, Y, BOARD) when (X + ?DIAG =< ?SIZE), (Y - ?DIAG  >= 1) ->
	case is_board_empty(X + ?DIAG, Y - ?DIAG, BOARD) of
		true -> 
			erlang:append_element(MOVES, {X + ?DIAG, Y - ?DIAG});
		false ->
			MOVES
	end;
go_up_right(MOVES, _, _, _) ->
	MOVES.

go_down_right(MOVES, X, Y, BOARD) when (X + ?DIAG =< ?SIZE), (Y + ?DIAG  =< ?SIZE) ->
	case is_board_empty(X + ?DIAG, Y + ?DIAG,BOARD) of
		true -> 
			erlang:append_element(MOVES, {X + ?DIAG, Y + ?DIAG});
		false ->
			MOVES
	end;
go_down_right(MOVES, _, _, _) ->
	MOVES.

go_down_left(MOVES, X, Y, BOARD) when (X - ?DIAG >= 1), (Y + ?DIAG  =< ?SIZE) ->
	case is_board_empty(X - ?DIAG, Y + ?DIAG,BOARD) of
		true -> 
			erlang:append_element(MOVES, {X - ?DIAG, Y + ?DIAG});
		false ->
			MOVES
	end;
go_down_left(MOVES, _, _, _) ->
	MOVES.



board_search_possible_moves(X,Y, BOARD) ->
	lists:foldl(fun(F, STATE) -> F(STATE) end, {},
	 [
	 	fun(S) -> go_down_left(S, X,Y, BOARD) end,
	 	fun(S) -> go_up_left(S, X, Y, BOARD) end,
	 	fun(S) -> go_left(S, X, Y, BOARD) end,
	 	fun(S) -> go_right(S, X, Y, BOARD) end,
	 	fun(S) -> go_down(S, X, Y, BOARD) end,
	 	fun(S) -> go_up(S, X, Y, BOARD) end,
	 	fun(S) -> go_up_right(S, X, Y, BOARD) end,
	 	fun(S) -> go_down_right(S, X, Y, BOARD) end
	 ]).

get_random_move(POSSIBLE_MOVES) when tuple_size(POSSIBLE_MOVES) > 0 ->
	element(rand:uniform(tuple_size(POSSIBLE_MOVES)), POSSIBLE_MOVES);
get_random_move(_) ->
	{}.

print_raport(BOARD, DELTATIME, MAXSCORE) ->
	io:fwrite("TIME: ~.16g~n", [DELTATIME]),
	io:fwrite("MAX SCORE ~p~n", [MAXSCORE]),
	lists:map(fun(ELEM) -> io:fwrite("~p~n", [ELEM]) end, tuple_to_list(BOARD)).               


check_start_time(STARTTIME, ITERATIONS, MAXBOARD, MAXSCORE) ->
	if
		ITERATIONS =:= 10000  ->
			DELTATIME = ((erlang:system_time() - STARTTIME) / 10000),
			print_raport(MAXBOARD, DELTATIME, MAXSCORE),
			{erlang:system_time(), 0};
		true -> 
			{STARTTIME, ITERATIONS}

	end.

check_if_maxscore(SCORE, MAXSCORE, BOARD, MAXBOARD) when MAXSCORE < SCORE ->
	{SCORE, BOARD};
check_if_maxscore(_, MAXSCORE, _, MAXBOARD) ->
	{MAXSCORE, MAXBOARD}.

run_game(GAME) ->
	PLAYER_X = GAME#ggame.player#player.x,
	PLAYER_Y = GAME#ggame.player#player.y,
	BOARD = GAME#ggame.board,
	MAXBOARD = GAME#ggame.max_board,
	SCORE = GAME#ggame.score,
	NEWSCORE = SCORE + 1,
	CHANGEDBOARD = board_set(PLAYER_X, PLAYER_Y, NEWSCORE, BOARD),
	POSSIBLE_MOVES = board_search_possible_moves(PLAYER_X, PLAYER_Y, BOARD),
	NEXT_MOVE = get_random_move(POSSIBLE_MOVES),
	ITERATIONS = GAME#ggame.iterations,
	MAXSCORE = GAME#ggame.max_score,
	% If there is no more moves.
	case tuple_size(NEXT_MOVE) == 0 of
		true ->
			% restart game
			{NEWMAXSCORE, NEWMAXBOARD} = check_if_maxscore(GAME#ggame.score, MAXSCORE, BOARD, GAME#ggame.max_board),
			run_game(new_game(NEWMAXBOARD, NEWMAXSCORE, ITERATIONS + 1));
		false ->
			% NEWSCORE = GAME#ggame.score + 1,
			% CHANGEDBOARD = board_set(element(1, NEXT_MOVE), element(2, NEXT_MOVE), NEWSCORE, BOARD),
			% print_raport(CHANGEDBOARD, 0.0),
			NEWPLAYER = #player{x=element(1, NEXT_MOVE), y=element(2, NEXT_MOVE)},
			{NEWSTARTTIME, NEWITERATIONS} = check_start_time(GAME#ggame.startTime, ITERATIONS, MAXBOARD, MAXSCORE),
			run_game(GAME#ggame{player=NEWPLAYER, board=CHANGEDBOARD, score=NEWSCORE, iterations=NEWITERATIONS, startTime=NEWSTARTTIME})

	end.


run() ->
	Game = new_game(new_board(), 0, 0),
	run_game(Game).



