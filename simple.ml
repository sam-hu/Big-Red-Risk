open Lymp
open Risk_state
open Command
open Board
open AI

(* change "python3" to the name of your interpreter *)
let interpreter = "python3"
let py = init ~exec:interpreter "."
let simple = get_module py "simple"
let riskgraphics = get_module py "riskgraphics"

(* Draws the board of the game*)
let board = get riskgraphics "drawBoard" []
let dice_results =
  Pytuple [Pylist[Pyint 6; Pyint 5; Pyint 3];Pylist[Pyint 6; Pyint 1;]]

(* Returns tuple of matching country *)
let rec get_country_tuple occupied_countries (target: string) =
  match occupied_countries with
  |[] -> Pynone
  |(c,p,i)::t -> if c.country_id = target
    then (Pytuple [Pystr c.country_id;Pystr p.player_id;Pyint i])
    else get_country_tuple t target

(* Convert occupied countries list to python*)
let rec occupied_countries_python occupied_countries acc =
  match occupied_countries with
  | [] -> Pylist acc
  |(c,p,i)::t ->
    occupied_countries_python t
      ((Pytuple [Pystr c.country_id;Pystr p.player_id;Pyint i])::acc)

(* Convert card amounts to python*)
let rec card_amounts_python player_list acc =
  match player_list with
  | [] -> Pylist acc
  | h::t -> card_amounts_python t
              ((Pytuple [Pystr h.player_id; Pyint (List.length h.cards)])::acc)

(* Get string of the current click to Python*)
let string_of_clicked clicked =
  match clicked with
  | Pytuple [Pystr strin; Pybool b] -> if strin = "Exit" then
      (Pervasives.print_endline "\nYou've quit Big Red Risk..."; exit 0)
    else strin
    | _ -> failwith "Should not be here1"

(* Get boolean of the current click to Python *)
let bool_of_clicked clicked =
  match clicked with
  | Pytuple [Pystr str; Pybool b] -> if str = "Exit" then
      (Pervasives.print_endline "\nYou've quit Big Red Risk..."; exit 0) else b
    | _ -> failwith "Should not be here2"


(* Get dice roll list into Python list *)
let rec roll_to_python (intlist: int list) acc =
  match intlist with
  | [] -> Pylist acc
  | h::t -> roll_to_python t ((Pyint h) :: acc)

(********** Call Python Graphics **********)

(* Updates the riskgraphics of board with the current click*)
let update_board_with_click the_state clicked notification=
  match clicked with
  | Pytuple [Pystr str; Pybool b] ->
    call riskgraphics "updateBoard"
      [board;clicked;get_country_tuple the_state.occupied_countries str;
       card_amounts_python the_state.active_players [];Pyint the_state.reward;
       Pyint the_state.total_turns;dice_results;
       Pystr the_state.player_turn.player_id;notification];
  | _ -> failwith "Should not be here3"

(* Updates the riskgraphics of board without a click*)
let update_board_no_click the_state notification =
  call riskgraphics "updateBoardNoClick"
    [board;Pynone;card_amounts_python the_state.active_players [];
     Pyint the_state.reward;Pyint the_state.total_turns;dice_results;
     Pystr the_state.player_turn.player_id;notification]

(* Update board graphics after attacks *)
let update_board_attack the_state clicked1 clicked2 notification =
  match clicked1,clicked2 with
  | Pytuple [Pystr str1; Pybool b1], Pytuple [Pystr str2; Pybool b2] ->
    call riskgraphics "updateAttack"
      [board;clicked1;get_country_tuple the_state.occupied_countries str1;
       get_country_tuple the_state.occupied_countries str2;
       card_amounts_python the_state.active_players [];Pyint the_state.reward;
       Pyint the_state.total_turns;dice_results;
       Pystr the_state.player_turn.player_id;notification];
  | _ -> failwith "Should not be here4"

(* Update board graphics to show the dice roll *)
let update_dice attdice defdice =
  try
  (call riskgraphics "updateDice"
     [roll_to_python attdice [];roll_to_python defdice [];board])
  with _ -> (Pervasives.print_endline "\nYou've quit Big Red Risk..."; exit 0)

let update_notification (notification) =
  call riskgraphics "updateNotificationBar" [notification]
let end_game_state (winner) =
  call riskgraphics "endgame" [board;Pystr winner]
let update_done_highlight (inputTuple) =
  call riskgraphics "updateOutlines" [inputTuple]

(********** Call Python Graphics End **********)

(* Below are the messages that show up on the GUI notification bar throughout
   the game, depending on the current state of the game.*)
let startgame_reinforce_notification st =
  Pystr (st.player_turn.player_id ^
         ": Please place a troop on an unoccupied country")

let startgame_populate_notification st =
  Pystr (st.player_turn.player_id ^
         ": Please place a troop on one of your countries")

let reinforce_notification st =
  Pystr (st.player_turn.player_id ^ ": Reinforce " ^
         (string_of_int st.player_turn.num_undeployed) ^ " troops")

let attack_notification_from st =
  Pystr (st.player_turn.player_id ^
         ": Select a country to attack from, or pass to fortification")

let attack_notification_to st =
  Pystr (st.player_turn.player_id ^
         ": Now, select an opponent's country to battle!")

let earn_card_notification st =
  Pystr (st.player_turn.player_id ^
         ": You earned a cash card for taking a country on your turn!")

let fortification_notification st =
  Pystr (st.player_turn.player_id ^
         ": Pull troops from one of your countries, or pass to end turn")

let eliminated_notification st =
  Pystr (st.player_turn.player_id ^ ": You eliminated a player from the game!")

let next_turn_notification st =
  Pystr (st.player_turn.player_id ^ ": It's your turn!")

let cash_in_notification st =
  Pystr (st.player_turn.player_id ^ ": Cashing in cards if available...")

(* returns true if current player is an AI, false otherwise *)
let is_ai st = if (st.player_turn.ai) then true else false

(* Runs a reinforcement function recursively of type [reinforce_cmd_type] until
   player has 0 undeployed troops remaining *)
let rec reinforce_type st reinforce_cmd_type rein_type =
  let undeploys = st.player_turn.num_undeployed in if (undeploys = 0) then st
  else if (is_ai st) then let next_string = ai_next_reinforce st in
    let cmd = reinforce_cmd_type (next_string) st in
    let st' = rein_type cmd st in
    (update_board_with_click st' (Pytuple [Pystr next_string; Pybool true])
       (if undeploys > 1 then reinforce_notification st'
        else attack_notification_from st'));
    reinforce_type st' reinforce_cmd_type rein_type
  else let clicked = get riskgraphics "clicker" [board] in
    update_notification (reinforce_notification st);
    if (bool_of_clicked clicked) then
      (let cmd = reinforce_cmd_type (string_of_clicked clicked) st in
       let st' = rein_type cmd st in
       (update_board_with_click st' clicked
          (if undeploys > 1 then reinforce_notification st' else if
             ((undeploys = 1) && (bool_of_clicked clicked = false)) ||
             ((undeploys = 1) && (owns_country (string_of_clicked clicked)
                                    st.occupied_countries st.player_turn<>true))
         then reinforce_notification st' else attack_notification_from st'));
       reinforce_type st' reinforce_cmd_type rein_type)
    else reinforce_type st reinforce_cmd_type rein_type

(* Runs a reinforcement function recursively until every country has been
   occupied with a troop *)
let rec reinforce_until_occupied_loop st =
  if (List.length st.occupied_countries = 24) then
    (update_board_no_click st (startgame_populate_notification st); st)
  else if (is_ai st) then let next_string = ai_next_initial_reinforce st in
    let cmd = init_reinforce_command (next_string) st in
    let st' = reinforce_begin cmd st in
    (update_board_with_click st' (Pytuple [Pystr next_string; Pybool true])
       (startgame_reinforce_notification st'));reinforce_until_occupied_loop st'
  else (
    let clicked = get riskgraphics "clicker" [board] in
    if (bool_of_clicked clicked) then
     let cmd = init_reinforce_command (string_of_clicked clicked) st in
     match cmd with
     | FalseReinforce -> reinforce_until_occupied_loop st
     | Reinforce _ -> (let st' = reinforce_begin cmd st in
                       update_board_with_click st' clicked
                         (startgame_reinforce_notification st');
                       reinforce_until_occupied_loop st')
    else reinforce_until_occupied_loop st)

(* Runs a reinforcement function recursively until all of the players'
   troops have been deployed *)
let rec reinforce_occupied_loop st =
  if (all_troops_deployed st.active_players) then st
  else
    (if (is_ai st) then let next_string = ai_next_reinforce st in
       let cmd = make_reinforce_command (next_string) st in
       let st' = next_player (reinforce cmd st) in
       update_board_with_click st' (Pytuple [Pystr next_string; Pybool true])
         (startgame_populate_notification st'); reinforce_occupied_loop st'
     else( let clicked = get riskgraphics "clicker" [board] in
       if (bool_of_clicked clicked) then
         let cmd = make_reinforce_command (string_of_clicked clicked) st in
         match cmd with
         |FalseReinforce -> reinforce_occupied_loop st
         |Reinforce _ ->
           (let st' = next_player (reinforce cmd st) in
            update_board_with_click st' clicked
              (startgame_populate_notification st');reinforce_occupied_loop st')
       else reinforce_occupied_loop st))

(* Creates a reinforcement loop for the middle of the game *)
let midgame_reinforce_loop st =
  reinforce_type st make_reinforce_command reinforce

(* Runs the post-attack reinforcement function recursively until all the
   player's undeployed troops are either in [option1] or [option2] *)
let rec reinforce_till_occupied_attack st option1 option2 =
  let undeploys = st.player_turn.num_undeployed in
  if st.player_turn.num_undeployed = 0 then st else
    (if is_ai st then
       let next_string = ai_next_reinforce_after_attack st option1 option2 in
       let cmd = make_reinforce_command next_string st in
       let st2 = reinforce cmd st in
       (update_board_with_click st2 (Pytuple [Pystr next_string; Pybool true])
          (if undeploys > 1 then reinforce_notification st2
           else attack_notification_from st2));
       reinforce_till_occupied_attack st2 option1 option2
     else let clicked = get riskgraphics "clicker" [board] in
       update_notification (reinforce_notification st);
       if bool_of_clicked clicked = false then
         reinforce_till_occupied_attack st option1 option2 else
         let clickedstring = string_of_clicked clicked in
         if clickedstring = option1 || clickedstring = option2 then
           let cmd = make_reinforce_command clickedstring st in
           let st2 = reinforce cmd st in
           (update_board_with_click st2 clicked
              (if undeploys > 1 then reinforce_notification st2 else if
                 ((undeploys = 1) && (bool_of_clicked clicked = false)) ||
                 ((undeploys = 1) &&
                  (owns_country (string_of_clicked clicked)
                     st.occupied_countries st.player_turn <> true))
               then reinforce_notification st2
               else attack_notification_from st2));
           reinforce_till_occupied_attack st2 option1 option2
         else reinforce_till_occupied_attack st option1 option2)

(* returns a new state in which the player's cards are traded in, if valid *)
let trade_in st = let cmd = make_trade_command st in trade_in cmd st

(* [fortify_loop] is recursively called until the player selects a valid country
   to fortify their troops from, and once that happens, calls one of the
   reinforcement loops, otherwise returns [st] if player chooses not to fortify
 *)
let rec fortify_loop st =
  update_notification (fortification_notification st);
  if(is_ai st) then
    let next_string = ai_next_fortify st in if next_string = "none" then
      (update_done_highlight (Pytuple [Pystr "End turn"; Pybool false]); st)
    else let cmd = make_fortify_command next_string st in
      let st' = fortify cmd st in
      update_board_with_click st' (Pytuple [Pystr next_string; Pybool true])
        (reinforce_notification st'); midgame_reinforce_loop st'
  else let clicked = get riskgraphics "clicker" [board] in
    if (string_of_clicked clicked = "End turn") then
      (update_done_highlight (Pytuple [Pystr "End turn"; Pybool false]);st) else
      let cmd = make_fortify_command (string_of_clicked clicked) st in
      let st' = fortify cmd st in
      if (st = st') then fortify_loop st
      else (update_board_with_click st' clicked (reinforce_notification st');
            midgame_reinforce_loop st')

(* simulates dice rolls by returning a list of random numbers from 1-6 which has
   length of [num_dice]
   Precondition: 1 <= [num_dice] <= 3*)
let roll num_dice = if (num_dice = 1) then [(Random.int 6)+1]
  else if (num_dice = 2) then [((Random.int 6)+1); (Random.int 6)+1]
  else [(Random.int 6)+1; (Random.int 6)+1; (Random.int 6)+1]

(* returns the highest value in [lst]
   Precondition: List.length [lst] > 0 *)
let find_max lst = (List.sort compare lst) |> List.rev |> List.hd

(* returns the 2nd highest value of [lst], -1 if List.length [lst] < 2 *)
let find_2nd_max lst =
  match List.rev (List.sort compare lst) with
  | h1::h2::t -> h2
  | _ -> -1

(* [get_click_two] is called recursively until the player clicks on a valid
   country to attack or clicks the DONE button, after which a tuple tuple is
   returned to reflect the player's clicks *)
let rec get_click_two st clicked1 clicked1string =
  let clicked2 = get riskgraphics "clicker" [board] in
  let clicked2string = (string_of_clicked clicked2) in
  if (owns_country clicked2string st.occupied_countries st.player_turn = true &&
      get_num_troops clicked2string st.occupied_countries > 1)
  then (update_board_with_click st clicked2 (attack_notification_to st);
        get_click_two st clicked2 clicked2string)
  else if owns_country clicked2string st.occupied_countries st.player_turn=true
  then (update_board_with_click st clicked2 (attack_notification_from st);
        get_click_two st clicked2 clicked2string)
  else (update_board_with_click st clicked2 (attack_notification_from st);
        ((clicked2, clicked2string),(clicked1,clicked1string)))

(* Simulates dice roll and returns a tuple that shows who lost how many troops*)
let roll_dice num_attackers num_defenders =
  let attack_dice = min (num_attackers-1) 3 in
  let defend_dice = min (num_defenders) 2 in
  let rolls = (roll attack_dice, roll defend_dice) in
  update_dice (fst rolls) ((snd rolls));
  let attack_max = find_max (fst rolls) in
  let attack_2nd_max = find_2nd_max (fst rolls) in
  let defend_max = find_max (snd rolls) in
  let defend_2nd_max = find_2nd_max (snd rolls) in
  if (attack_dice > 1 && defend_dice > 1) then
    (if (attack_max > defend_max && attack_2nd_max > defend_2nd_max)
     then (Right, -2) else if
       (attack_max <= defend_max && attack_2nd_max <=  defend_2nd_max)
     then (Left, -2) else (Both, -1))
  else (if (attack_max > defend_max) then (Right, -1) else (Left, -1))


(* [attack_loop st] is a loop that keeps running while the player is attacking
   another player in environment [st], returns a new state when the user
   presses the DONE button to pass their turn *)
let rec attack_loop st = Random.init (int_of_float (Unix.time ()));
  if is_ai st then let next_tuple = ai_next_attack st in
    let next_attack = fst next_tuple in let next_defender = snd next_tuple in
    if next_tuple = ("none", "none")
    then (update_done_highlight (Pytuple [Pystr "End turn"; Pybool false]); st)
    else let num_attackers = get_num_troops next_attack st.occupied_countries in
      update_board_with_click st (Pytuple [Pystr next_attack; Pybool true])
        (attack_notification_to st);
      update_board_with_click st (Pytuple [Pystr next_defender; Pybool true])
        (attack_notification_to st);
      let num_defenders = get_num_troops next_defender st.occupied_countries in
      let loser_lost = roll_dice num_attackers num_defenders in
      let cmd = make_attack_command next_attack next_defender
          (fst loser_lost) (snd loser_lost) st in
      let st2 = attack cmd st in
      (if (num_countries st2.player_turn st2.occupied_countries 0 >
           num_countries st.player_turn st.occupied_countries 0
           && st2.player_turn.num_undeployed > 0) then
         update_board_attack st2 (Pytuple [Pystr next_attack; Pybool true])
           (Pytuple [Pystr next_defender; Pybool true])
           (reinforce_notification st2) else
         update_board_attack st2 (Pytuple [Pystr next_attack; Pybool true])
           (Pytuple [Pystr next_defender; Pybool true])
           (attack_notification_from st2));
      if num_countries st2.player_turn st2.occupied_countries 0 = 24 then st2
      else if num_countries st2.player_turn st2.occupied_countries 0 >
              num_countries st.player_turn st.occupied_countries 0 then
        let st3=reinforce_till_occupied_attack st2 next_attack next_defender in
        attack_loop st3 else attack_loop st2
  else let clicked1 = get riskgraphics "clicker" [board] in
    let clicked1string = (string_of_clicked clicked1) in
    if (clicked1string = "End turn") then
      (update_board_with_click st clicked1 (Pystr "");
       update_done_highlight (Pytuple [Pystr "End turn"; Pybool false]); st)
    else if
      (owns_country clicked1string st.occupied_countries st.player_turn <> true)
    then ((update_board_with_click st clicked1 (attack_notification_from st));
          attack_loop st)
    else if get_num_troops clicked1string st.occupied_countries = 1
    then ((update_board_with_click st clicked1 (attack_notification_from st));
          attack_loop st)
    else (update_board_with_click st clicked1 (attack_notification_to st);
       let clicked2stringtuple = get_click_two st clicked1 clicked1string in
       if clicked2stringtuple = ((Pystr "false",""),(Pystr "",""))
       then attack_loop st else
         let clicked2 = fst (fst clicked2stringtuple) in
         let clicked2string = snd (fst clicked2stringtuple) in
         let clicked1 = fst (snd clicked2stringtuple) in
         let clicked1string = snd (snd clicked2stringtuple) in
         if (clicked2string = "End turn") then
           (update_done_highlight (Pytuple [Pystr "End turn"; Pybool false]);st)
         else let num_attackers =
                get_num_troops clicked1string st.occupied_countries in
           let num_defenders=get_num_troops clicked2string st.occupied_countries
           in if (num_attackers < 2) then attack_loop st else
             (let loser_lost = roll_dice num_attackers num_defenders in
              let cmd = make_attack_command (string_of_clicked clicked1)
                     (string_of_clicked clicked2) (fst loser_lost)
                     (snd loser_lost) st in let st2 = attack cmd st in
              (if (num_countries st2.player_turn st2.occupied_countries 0 >
                   num_countries st.player_turn st.occupied_countries 0
                   && st2.player_turn.num_undeployed > 0) then
                 update_board_attack st2 clicked1 clicked2
                   (reinforce_notification st2) else
                 update_board_attack st2 clicked1 clicked2
                   (attack_notification_from st2));
              if num_countries st2.player_turn st2.occupied_countries 0 = 24
              then st2 else if
                num_countries st2.player_turn st2.occupied_countries 0 >
                num_countries st.player_turn st.occupied_countries 0 then
                let st3 = reinforce_till_occupied_attack st2
                    clicked1string clicked2string in attack_loop st3
              else attack_loop (st2)))

(* returns the player who owns the most countries in [st] *)
let rec get_winner player_list st acc =
  match player_list with
  |[] -> acc
  |h::t ->
    if (List.length (get_my_countries h st.occupied_countries []) > snd acc)
    then get_winner t st
        (h, List.length (get_my_countries h st.occupied_countries []))
    else get_winner t st acc

(* [repl st has_won] is the heart of the game's REPL. It performs all actions
   in the RISK Board Game systematically for every player. It is initially
   called with an initial state for [st] and a False for [has_won], and is
   called recursively until [has_won] is true
   Preconditions: [st] is a valid state *)
let rec repl st has_won =
  if (has_won || st.total_turns = 50) then
    end_game_state (fst (get_winner st.active_players st
                           (List.hd st.active_players, 0))).player_id else
    ((update_board_no_click st (Pystr "")); let st' = build_continent_list st in
     let st1 = trade_in st' in
     (update_board_no_click st1 (cash_in_notification st1)); Unix.sleep 2;
     let st1' = give_troops st1 in
     update_notification (reinforce_notification st1');
     let st2 = midgame_reinforce_loop (st1') in
     let st3 = attack_loop st2 in (update_board_no_click st3) (Pystr "");
     if num_countries st3.player_turn st3.occupied_countries 0 = 24
     then repl st3 true else let st4 = give_card st2 st3 in
       (if st3 = st4 then update_board_no_click st4 (Pystr "") else
          (update_board_no_click st4 (earn_card_notification st4);
           Unix.sleep 2)); let st5 = fortify_loop st4 in
       (update_board_no_click st4) (Pystr ""); let st6 = remove_player st5 in
       (if st5 = st6 then update_board_no_click st6 (Pystr "") else
          (update_board_no_click st6 (eliminated_notification st6);
           Unix.sleep 2)); let st7 = next_player st6 in
       (update_board_no_click st7) (next_turn_notification st7);
       let won = check_if_win st7 in repl st7 won)

(* Receives user input for number of AI's and aggressiveness of each AI *)
let rec get_num_AI num_players =
  let num = string_of_int num_players in
  ANSITerminal.(
    print_string [green]
      ("How many of those would you like to be AI's? (0-"^num^")\n> "));
 let num_AI = try (int_of_string (read_line ()))
   with _ ->(ANSITerminal.(print_string [red]
                             ("\nPlease enter an integer from 0 to "^num^"\n"));
      get_num_AI num_players) in
 if (num_AI >= 0 && num_AI <= num_players) then num_AI
 else (ANSITerminal.(print_string [red]
                       ("\nPlease enter an integer from 0 to "^num^"\n"));
       get_num_AI num_players)

(* Receives user input for number of players and AI's to play with in the game*)
let rec get_num_players () =
  ANSITerminal.(print_string [green]
                  ("How many players would you like to play with? (2-4)\n> "));
 let num_players = try (int_of_string (read_line ()))
   with _ -> ANSITerminal.(print_string [red]
                             ("\nPlease enter an integer from 2 to 4\n"));
     get_num_players ()
 in if (num_players >= 2 && num_players <= 4) then num_players
 else (ANSITerminal.(print_string [red]
                       ("\nPlease enter an integer from 2 to 4\n"));
       get_num_players ())

(* Sets a ratio for AI aggressiveness based on user input *)
let rec set_ai_ratio ai =
  ANSITerminal.(print_string [green]
                  ("How aggressive would you like "^ai.player_id^" to be?
(0-10) with 0 being least aggressive and 10 being most aggressive\n> "));
  let input = try (float_of_string (read_line ()))
    with _ -> ANSITerminal.(print_string [red]
                              ("\nPlease enter a float from 0 to 10\n"));
      set_ai_ratio ai
  in if (input >= 0. && input <= 10.) then (2.-.(input/.10.))
  else (ANSITerminal.(print_string [red]
                        ("\nPlease enter a float from 0 to 10\n"));
        set_ai_ratio ai)

(* Initialize a list of AI's with the ratio determined by user input *)
let rec initialize_ais ai_list =
  match ai_list with
  | [] -> []
  | h::t -> {h with ratio = set_ai_ratio h}::initialize_ais t

(* Main function that goes through all the functions of the game *)
let () = ANSITerminal.(print_string [green] ("Welcome to Big Red Risk!\n"));
  let num_players = get_num_players () in let num_AI = get_num_AI num_players in
  let num_humans = num_players - num_AI in
  let num_starting =
    (if (num_players = 2) then 15 else if (num_players = 3) then 10 else 8) in
  let ai_list = if (num_AI = 0) then []
    else if (num_AI = 1 && num_humans = 3)
    then [{ai4 with num_undeployed = num_starting}]
    else if (num_AI = 1 && num_humans = 2)
    then [{ai3 with num_undeployed = num_starting}]
    else if (num_AI = 1 && num_humans = 1)
    then [{ai2 with num_undeployed = num_starting}]
    else if (num_AI = 2 && num_humans = 2)
    then [{ai3 with num_undeployed = num_starting};
          {ai4 with num_undeployed = num_starting}]
    else if (num_AI = 2 && num_humans = 1)
    then [{ai2 with num_undeployed = num_starting};
          {ai3 with num_undeployed = num_starting}]
    else if (num_AI = 2 && num_humans = 0)
    then [{ai1 with num_undeployed = num_starting};
          {ai2 with num_undeployed = num_starting}]
    else if (num_AI = 3 && num_humans = 1)
    then [{ai2 with num_undeployed = num_starting};
          {ai3 with num_undeployed = num_starting};
          {ai4 with num_undeployed = num_starting}]
    else if (num_AI = 3 && num_humans = 0)
    then [{ai1 with num_undeployed = num_starting};
          {ai2 with num_undeployed = num_starting};
          {ai3 with num_undeployed = num_starting}]
    else [{ai1 with num_undeployed = num_starting};
          {ai2 with num_undeployed = num_starting};
          {ai3 with num_undeployed = num_starting};
          {ai4 with num_undeployed = num_starting}] in
  let human_list = if (num_humans = 0) then []
    else if (num_humans = 1) then [{p1 with num_undeployed = num_starting}]
    else if (num_humans = 2) then [{p1 with num_undeployed = num_starting};
                                   {p2 with num_undeployed = num_starting}]
    else if (num_humans = 3) then [{p1 with num_undeployed = num_starting};
                                   {p2 with num_undeployed = num_starting};
                                   {p3 with num_undeployed = num_starting}]
    else [{p1 with num_undeployed = num_starting};
          {p2 with num_undeployed = num_starting};
          {p3 with num_undeployed = num_starting};
          {p4 with num_undeployed = num_starting}] in
  let player_list = human_list@(List.rev (initialize_ais (List.rev ai_list))) in
  let i_state = init_state num_players player_list graphboard in
  update_notification (startgame_reinforce_notification i_state);
  let st1 = reinforce_until_occupied_loop i_state in
  let st2 = reinforce_occupied_loop st1 in repl st2 false
