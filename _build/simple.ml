open Lymp
open Risk_state
open Command
open Board

(* change "python3" to the name of your interpreter *)
let interpreter = "python3"
let py = init ~exec:interpreter "."
let simple = get_module py "simple"
let graphics = get_module py "graphics"

(* Prints the input list*)
let rec print_list = function
  | [] -> ()
  | e::l -> Pervasives.print_int e ; Pervasives.print_string " " ; print_list l

(* Draws the board of the game*)
let board = get graphics "drawBoard" []
let dice_results = Pytuple [Pylist[Pyint 6; Pyint 5; Pyint 3];Pylist[Pyint 6; Pyint 1;]]

(* Convert occupied countries list to python*)
let rec occupied_countries_python occupied_countries acc =
  match occupied_countries with
  | [] -> Pylist acc
  |(c,p,i)::t -> occupied_countries_python t
                   ((Pytuple [Pystr c.country_id;Pystr p.player_id;Pyint i]) :: acc)
(* Convert card amounts to python*)
let rec card_amounts_python player_list acc =
  match player_list with
  | [] -> Pylist acc
  | h::t -> card_amounts_python t
              ((Pytuple [Pystr h.player_id; Pyint (List.length h.cards)]) :: acc)
(* Get string of the current click*)
let string_of_clicked clicked =
match clicked with
    | Pytuple [Pystr strin; Pybool b] -> strin
    | _ -> failwith "Should not be here"
(* Get boolean of the current click*)
let bool_of_clicked clicked =
match clicked with
    | Pytuple [Pystr str; Pybool b] -> b
    | _ -> failwith "Should not be here"
(* Get a click action from the user as a tuple (string,bool), with [string]
   representing the name of the country/button and bool is True if the click
   is inside of a country*)
let get_click = get graphics "clicker" [board]
(* Updates the graphics of board with the current click*)
let update_board_with_click the_state clicked =
  match clicked with
  | Pytuple [Pystr str; Pybool b] -> call graphics "updateBoard"
  [board;clicked;occupied_countries_python the_state.occupied_countries [];
  card_amounts_python the_state.active_players [];Pyint the_state.reward;
  Pyint the_state.total_turns;dice_results;Pystr the_state.player_turn.player_id];
  | _ -> failwith "Should not be here"
(* Updates the graphics of board without a click*)
let update_board_no_click the_state = call graphics "updateBoardNoClick"
  [board;occupied_countries_python the_state.occupied_countries [];
   card_amounts_python the_state.active_players [];Pyint the_state.reward;
  Pyint the_state.total_turns;dice_results;Pystr the_state.player_turn.player_id]

(* Get time of computer system*)
let time = int_of_float (Sys.time ())

(* Creates a reinforcement loop that performs the reinforcement action*)
let rec reinforce_type st reinforce_cmd_type rein_type =
  if (st.player_turn.num_undeployed = 0) then st
  else
    let clicked = get graphics "clicker" [board] in
    if (bool_of_clicked clicked) then
      (let cmd = reinforce_cmd_type (string_of_clicked clicked) st in
    let st' = rein_type cmd st in update_board_with_click st' clicked;
       reinforce_type st' reinforce_cmd_type rein_type) else st

let rec reinforce_until_occupied_loop st =
 if (List.length st.occupied_countries = 3) then st (*3 is hard-coded*)
 else
   let clicked = get graphics "clicker" [board] in
   if (bool_of_clicked clicked) then
     let cmd = init_reinforce_command (string_of_clicked clicked) st in
     match cmd with
     | FalseReinforce -> reinforce_until_occupied_loop st
     | Reinforce _ ->
     (let st' = reinforce_begin cmd st in update_board_with_click st' clicked;
      reinforce_until_occupied_loop st')
   else st

let rec reinforce_occupied_loop st =
 if (all_troops_deployed st.active_players) then st
 else
   let clicked = get graphics "clicker" [board] in
   if (bool_of_clicked clicked) then
     let cmd = make_reinforce_command (string_of_clicked clicked) st in
     match cmd with
     | FalseReinforce -> reinforce_occupied_loop st
     | Reinforce _ ->
       (let st' = next_player (reinforce cmd st) in update_board_with_click st' clicked;
        Pervasives.print_endline st'.player_turn.player_id;
     reinforce_occupied_loop st')
   else st
(* Creates a reinforcement loop for the middle of the game*)
let midgame_reinforce_loop st = reinforce_type st make_reinforce_command reinforce
(* Creates a reinforcement loop for the start of the game when players
   begin claiming countries*)
(* let startgame_reinforce_loop st = reinforce_type st init_reinforce_command reinforce_begin *)

let trade_in st =
  let cmd = make_trade_command st in
  trade_in cmd st

let rec fortify_loop st =
  let clicked = get graphics "clicker" [board] in
  let cmd = make_fortify_command (string_of_clicked clicked) st in
  let st' = fortify cmd st in
  if (st = st') then fortify_loop st
  else st'

let roll num_dice = if (num_dice = 1) then [(Random.int 6)+1]
  else if (num_dice = 2) then [((Random.int 6)+1); (Random.int 6)+1]
  else [(Random.int 6)+1; (Random.int 6)+1; (Random.int 6)+1]

let find_max lst = (List.sort compare lst) |> List.rev |> List.hd

let find_2nd_max lst =
  match List.rev (List.sort compare lst) with
  | h1::h2::t -> h2
  | _ -> -1

(* Creates an attack loop that can be existed if user hits end turn*)
let rec attack_loop st =   (*have to check if one side lost*)
  Random.init (int_of_float (Unix.time ()));
  let clicked1 = get graphics "clicker" [board] in
  let clicked1string = (string_of_clicked clicked1) in update_board_with_click st clicked1;
  if (clicked1string = "End turn") then st else 
  let clicked2 = get graphics "clicker" [board] in
  let clicked2string = (string_of_clicked clicked2) in
  if (clicked2string = "End turn") then st else

  let num_attackers = get_num_troops clicked1string st.occupied_countries in
  let num_defenders = get_num_troops clicked2string st.occupied_countries in
  if (num_attackers < 2) then attack_loop st
  else (let attack_dice = min (num_attackers-1) 3 in
        let defend_dice = min (num_defenders) 2 in
        let rolls = (roll attack_dice, roll defend_dice) in
        print_list (fst rolls); print_list (snd rolls);
        let attack_max = find_max (fst rolls) in
        let attack_2nd_max = find_2nd_max (fst rolls) in
        let defend_max = find_max (snd rolls) in
        (* Pervasives.print_endline (string_of_int attack_max); Pervasives.print_endline (string_of_int defend_max); *)
        let defend_2nd_max = find_2nd_max (snd rolls) in
        let loser_lost = if (attack_dice > 1 && defend_dice > 1) then
            (if (attack_max > defend_max && attack_2nd_max > defend_2nd_max) then (Right, -2)
             else if (attack_max <= defend_max && attack_2nd_max <=  defend_2nd_max) then (Left, -2)
             else (Both, -1))
          else (if (attack_max > defend_max) then (Right, -1) else (Left, -1)) in
        let cmd = make_attack_command (string_of_clicked clicked1) (string_of_clicked clicked2)
                                      (fst loser_lost) (snd loser_lost) st in
        let st2 = attack cmd st in update_board_with_click st2 clicked2;
        attack_loop (st2))

(* [repl st has_won] is the heart of the game's REPL. It performs all actions
    in the RISK Board Game systematically for every player. It is initially
    called with an initial state for [st] and a False for [has_won]
   Preconditions: [st] is a state
                  [has_won] is a boolean
*)
let rec repl st has_won =
  if (has_won) then st (*display win message*)
  else
    let st' = build_continent_list st in
    let st1 = trade_in st' in (update_board_no_click st1);
    let st2 = midgame_reinforce_loop (give_troops st1) in
    let st3 = attack_loop st2 in (update_board_no_click st3);
    let st4 = give_card st2 st3 in (update_board_no_click st4);
    let clicked1 = get graphics "clicker" [board] in
    st4



let p1 = {
  player_id = "Player one";
  num_deployed = 0;
  num_undeployed = 3;
  cards = [];
  score = 0;
}

let p2 = {
  player_id = "Player two";
  num_deployed = 0;
  num_undeployed = 3;
  cards = [];
  score = 0;
}

let p3 = {
  player_id = "Player three";
  num_deployed = 0;
  num_undeployed = 3;
  cards = [];
  score = 0;
}
(* let clicked = get graphics "clicker" [board] in
(match clicked with
  | Pytuple [Pystr st; Pybool b] ->
  call graphics "updateBoard"
  [board;
  clicked;
  occupied_countries_python st1.occupied_countries [];
  card_amounts_python st1.active_players [];
  Pyint st1.reward;
  Pyint st1.total_turns;
  dice_results;
  Pystr st1.player_turn.player_id];
  | _ -> failwith "Should not be here")
); *)

let () =
  (* msg = simple.get_message() *)

  let i_state = init_state 3 [p1;p2;p3] in
  (*let st = startgame_reinforce_loop i_state in *)
  let st1 = reinforce_until_occupied_loop i_state in
  let st2 = reinforce_occupied_loop st1 in
  repl st2 false;


(*
  let board = get graphics "drawBoard" [] in
  let dice_results = Pytuple [Pylist[Pyint 6; Pyint 5; Pyint 3];Pylist[Pyint 6; Pyint 1;]] in

  let i_state = init_state 3 [p1;p2;p3] in

(* loop_repl i_state False *)
  let quit_loop = ref false in
  while not !quit_loop do
  print_string "Have you had enough yet? (y/n) ";

  let clicked = get graphics "clicker" [board] in
  let s = match clicked with
    | Pytuple [Pystr st; Pybool b] ->
      call graphics "updateBoard"
          [board;
           clicked;
           occupied_countries_python i_state.occupied_countries [];
           card_amounts_python i_state.active_players [];
           Pyint i_state.reward;
           Pyint i_state.total_turns;
           dice_results;
           Pystr i_state.player_turn.player_id]
    | _ -> failwith "Should not be here"
  in s;
  done;; *)

  (* let init_state player_num players = {
    num_players = player_num;
    player_turn = List.hd players;
    total_turns = 0;
    active_players = players;
    reward = 5;
    occupied_countries = [];
    occupied_continents = [];
    board = board;
  } *)
(*
  let occupied_countries = Pylist [Pytuple [Pystr "Country one";Pystr "Player one";Pyint 556];
                                   Pytuple [Pystr "Country two";Pystr "Player one";Pyint 22];
                                   Pytuple [Pystr "Country three";Pystr "Player three";Pyint 486]] in
  let card_amounts = Pylist [Pytuple [Pystr "Player one";Pyint 5];
                             Pytuple [Pystr "Player two";Pyint 2];
                             Pytuple [Pystr "Player three";Pyint 1];] in

  let cash_card_reward = Pyint 15 in
  let dice_results = Pytuple [Pylist[Pyint 6; Pyint 5; Pyint 3];Pylist[Pyint 6; Pyint 1;]] in
  let turns_taken = 3 in

  let board = get graphics "drawBoard" [Pystr "Player one"] in
  let player_ids = ["Player one";"Player two";"Player three"] in
  let current_player_turn = "Player one" in

  let quit_loop = ref false in
  while not !quit_loop do
    print_string "Have you had enough yet? (y/n) ";

    let clicked = get graphics "clicker" [board] in
    let s = match clicked with
      | Pytuple [Pystr st; Pybool b] ->
        if (st = "End turn") then call graphics "updateBoard"
          [board;clicked;occupied_countries;card_amounts;cash_card_reward;
           Pyint turns_taken; dice_results;Pystr current_player_turn]
        else call graphics "updateBoard"
            [board;clicked;occupied_countries;card_amounts;cash_card_reward;
             Pyint turns_taken; dice_results;Pystr current_player_turn]
      | _ -> failwith "Should not be here"
    in s;

  (* let str = read_line () in
  if str.[0] = 'y' then
    quit_loop := true *)
    done;; *)



  (* let msg = get_string simple "get_message" [] in
	let integer = get_int simple "get_integer" [] in
	let addition = get_int simple "sum" [Pyint 12 ; Pyint 10] in
	let strconcat = get_string simple "sum" [Pystr "first " ; Pystr "second"] in
  Printf.printf "%s\n%d\n%d\n%s\n" msg integer addition strconcat ; *)



	close py
