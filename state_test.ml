open OUnit2
open Risk_state
open Command
open Board

let p1 = {
  player_id = "player 1";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}

let p2 = {
  player_id = "player 2";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}

let p3 = {
  player_id = "player 3";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [Circle; Circle; Circle];
  ai = false;
  ratio = 0.0
}

let p4 = {
  player_id = "player 4";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [Circle; Triangle; Square];
  ai = false;
  ratio = 0.0
}

let p_new = {
  player_id = "player new";
  num_deployed = 0;
  num_undeployed = 3;
  cards = [];
  ai = false;
  ratio = 0.0
}

let players = [p1;p2;p3;p4]
let players2 = [p1;p2;p3]
let player_one = [p1]
let players_new = [p1;p2;p_new;p3]

let country1 = {
  country_id = "USA";
  bordering_countries = ["Canada";"Mexico"]
}

let country2 = {
  country_id = "Canada";
  bordering_countries = ["USA"]
}

let country3 = {
  country_id = "Mexico";
  bordering_countries = ["USA"]
}

let country4 = {
  country_id = "Cuba";
  bordering_countries = ["USA";"Mexico"]
}

let continent = {
  countries = [country1; country2; country3; country4];
  id = "North America";
  bonus = 5;
}

let board = [continent]

let state = {
  num_players = 4;
  player_turn = p1;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let state2 = {
  num_players = 3;
  player_turn = p1;
  total_turns = 0;
  active_players = players2;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let state_one_p = {
  num_players = 1;
  player_turn = p1;
  total_turns = 0;
  active_players = player_one;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let state3 = {
  num_players = 4;
  player_turn = p3;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let before_attack = {
  num_players = 3;
  player_turn = {p1 with num_deployed = 3};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 3};{p2 with num_deployed = 2};p3];
  reward = 5;
  occupied_countries = [(country1, p1, 3);(country2, p2, 2);(country3, p3, 2)];
  player_continents = [];
  board = board;
}

let after_attack = {
  num_players = 3;
  player_turn = {p1 with num_deployed = 2; num_undeployed = 1};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2; num_undeployed = 1};{p2 with num_deployed = 0};{p3 with num_deployed = 2}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 2; num_undeployed = 1}, 1);(country2, {p1 with num_deployed = 2; num_undeployed = 1}, 1);(country3, p3, 2)];
  player_continents = [];
  board = board;
}

let before_remove = {
  num_players = 3;
  player_turn = {p1 with num_deployed = 2; num_undeployed = 1};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2; num_undeployed = 1};{p2 with num_deployed = 0};{p3 with num_deployed = 2}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 2; num_undeployed = 1}, 1);(country2, {p1 with num_deployed = 2; num_undeployed = 1}, 1);(country3, {p3 with num_deployed = 2}, 2)];
  player_continents = [];
  board = board;
}

let before_attack_two = {
  num_players = 3;
  player_turn = {p1 with num_deployed = 3};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 3};{p2 with num_deployed = 4};{p3 with num_deployed = 2}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 3}, 3);(country2, {p2 with num_deployed = 4}, 4);(country3, {p3 with num_deployed = 2}, 2)];
  player_continents = [];
  board = board;
}

let after_attack_two = {
  num_players = 3;
  player_turn = {p1 with num_deployed = 2};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2};{p2 with num_deployed = 4};{p3 with num_deployed = 1}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 2}, 2);(country2, {p2 with num_deployed = 4}, 4);(country3, {p3 with num_deployed = 1}, 1)];
  player_continents = [];
  board = board;
}

let reinforced_one = {
  num_players = 4;
  player_turn = p2;
  total_turns = 0;
  active_players = [{p1 with num_deployed = 1; num_undeployed = -1};p2;p3;p4];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 1; num_undeployed = -1}, 1)];
  player_continents = [];
  board = board;
}

let reinforced_one_again_prev = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 1; num_undeployed = -1};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 1; num_undeployed = -1};p2;p3;p4];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 1; num_undeployed = -1}, 1)];
  player_continents = [];
  board = board;
}

let reinforced_one_again = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 2; num_undeployed = -2};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2; num_undeployed = -2};p2;p3;p4];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 2; num_undeployed = -2}, 2)];
  player_continents = [];
  board = board;
}

let reinforced_two = {
  num_players = 4;
  player_turn = p2;
  total_turns = 0;
  active_players = [{p1 with num_deployed = 1; num_undeployed = -1};p2;p3];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 1; num_undeployed = -1}, 1)];
  player_continents = [];
  board = board;
}

let reinforced_two_again_prev = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 1; num_undeployed = -1};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 1; num_undeployed = -1};p2;p3];
  reward = 5;
  occupied_countries = [(country4, {p1 with num_deployed = 1; num_undeployed = -1}, 1)];
  player_continents = [];
  board = board;
}

let reinforced_two_again = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 2; num_undeployed = -2};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2; num_undeployed = -2};p2;p3];
  reward = 5;
  occupied_countries = [(country4, {p1 with num_deployed = 2; num_undeployed = -2}, 2)];
  player_continents = [];
  board = board;
}

let fortify_one = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 4};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 4}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 4}, 3);(country3,{p1 with num_deployed = 4},1)];
  player_continents = [];
  board = board;
}

let fortify_one_after = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 2; num_undeployed = 2};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 2; num_undeployed = 2}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 2; num_undeployed = 2}, 1);(country3,{p1 with num_deployed = 2; num_undeployed = 2},1)];
  player_continents = [];
  board = board;
}

let fortify_before = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 8};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 8}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 8}, 3);(country3,{p1 with num_deployed = 8},5)];
  player_continents = [];
  board = board;
}

let fortify_after = {
  num_players = 4;
  player_turn = {p1 with num_deployed = 4; num_undeployed = 4};
  total_turns = 0;
  active_players = [{p1 with num_deployed = 4; num_undeployed = 4}];
  reward = 5;
  occupied_countries = [(country1, {p1 with num_deployed = 4; num_undeployed = 4}, 3);(country3,{p1 with num_deployed = 4; num_undeployed = 4},1)];
  player_continents = [];
  board = board;
}

let make_trade_state = {
  num_players = 4;
  player_turn = p3;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let trade_in_state = {
  num_players = 4;
  player_turn = p3;
  total_turns = 0;
  active_players = players;
  reward = 10;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let make_trade_diff = {
  num_players = 4;
  player_turn = p4;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let state_new = {
  num_players = 4;
  player_turn = p2;
  total_turns = 1;
  active_players = [{p2 with num_undeployed = 1}];
  reward = 5;
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let attack_command = Attack ("USA","Canada",Right,-2)

let attack_command_two = Attack ("USA","Mexico",Both,-1)

let reinforce_begin_command = Reinforce "USA"

let reinforce_begin_command2 = Reinforce "Cuba"

let tests =[
  (* tests for init_state make it fail when passed an empty case? *)
  "init_state" >:: (fun _ -> assert_equal state (init_state 4 players board));
  "init_state2" >:: (fun _ -> assert_equal state2 (init_state 3 players2 board));
  "init_state3" >:: (fun _ -> assert_equal state_one_p (init_state 1 player_one board));

  (* tests for reinforce*)
  "begin_reinforce1" >:: (fun _ -> assert_equal reinforced_one (init_state 4 players board |> reinforce_begin reinforce_begin_command));
  "begin_reinforce2" >:: (fun _ -> assert_equal reinforced_two (init_state 4 players2 board |> reinforce_begin reinforce_begin_command));
  "begin_reinforce3" >:: (fun _ -> assert_equal state (init_state 4 players board |> reinforce_begin FalseReinforce));

  (*check turns*)
  "reinforce 4" >:: (fun _ -> assert_equal reinforced_one_again (reinforced_one_again_prev |> reinforce reinforce_begin_command));
  "reinforce 5" >:: (fun _ -> assert_equal reinforced_two_again (reinforced_two_again_prev |> reinforce reinforce_begin_command2));
  "reinforce 6" >:: (fun _ -> assert_equal state (init_state 4 players board |> reinforce FalseReinforce));

  (* tests for next player*)
  "next player" >:: (fun _ -> assert_equal {state with total_turns = 1} (state |> next_player |> next_player |> next_player |> next_player));
  "next player 2" >:: (fun _ -> assert_equal {state2 with player_turn = p2} (state2 |> next_player));
  "next player 3" >:: (fun _ -> assert_equal state3 (init_state 4 players board |> next_player |> next_player));

  (* tests for attack (check what Right and Left) *)
  "attack 1" >:: (fun _ -> assert_equal after_attack (attack attack_command before_attack));
  "attack 2" >:: (fun _ -> assert_equal after_attack_two (attack attack_command_two before_attack_two));
  "attack 3" >:: (fun _ -> assert_equal before_attack (attack FalseAttack before_attack));

  (* tests for fortify*)
  "fortify 1" >:: (fun _ -> assert_equal state (fortify FalseFortify state));
  "fortify 2" >:: (fun _ -> assert_equal fortify_one_after (fortify (Fortify "USA") fortify_one));
  "fortify 3" >:: (fun _ -> assert_equal fortify_after (fortify (Fortify "Mexico") fortify_before));

  (* tests for make_trade_command *)
  "trade1" >:: (fun _ -> assert_equal (Same Circle) (make_trade_command make_trade_state));
  "trade2" >:: (fun _ -> assert_equal Different (make_trade_command make_trade_diff));
  "trade3" >:: (fun _ -> assert_equal NoTrade (make_trade_command state));

  (* tests for trade_in *)
  "trade_in1" >:: (fun _ -> assert_equal [] (trade_in (Same Circle) make_trade_state).player_turn.cards);
  "trade_in2" >:: (fun _ -> assert_equal [] (trade_in Different make_trade_diff).player_turn.cards);
  "trade_in3" >:: (fun _ -> assert_equal state (trade_in  NoTrade state));

  (* tests for make reinforce command *)
  "make_reinforce1" >:: (fun _ -> assert_equal true (make_reinforce_command "USA" before_attack |> is_reinforce));
  "make_reinforce2" >:: (fun _ -> assert_equal false (make_reinforce_command "Cuba" reinforced_two |> is_reinforce));
  "make_reinforce3" >:: (fun _ -> assert_equal FalseReinforce (make_reinforce_command "USA" state));

  (* tests for give troops*)
  "give1" >:: (fun _ -> assert_equal 3 (give_troops state).player_turn.num_undeployed);
  "give2" >:: (fun _ -> assert_equal 3 (give_troops state2).player_turn.num_undeployed);

  (* tests for remove player*)
  "remove1" >:: (fun _ -> assert_equal [{p1 with num_deployed = 2; num_undeployed = 1};{p3 with num_deployed = 2}] (remove_player before_remove).active_players);
  "remove2" >:: (fun _ -> assert_equal [] (remove_player state).active_players);
  "remove3" >:: (fun _ -> assert_equal [] (remove_player state2).active_players);

  (* tests for owns_country*)
  "owns1" >:: (fun _ -> assert_equal true (owns_country "USA" before_attack.occupied_countries p1));
  "owns2" >:: (fun _ -> assert_equal true (owns_country "Mexico" after_attack.occupied_countries p3));
  "owns3" >:: (fun _ -> assert_equal false (owns_country "USA" state.occupied_countries p2));

  (* tests for all troops deployed*)
  "deployed1" >:: (fun _ -> assert_equal true (all_troops_deployed state.active_players));
  "deployed2" >:: (fun _ -> assert_equal true (all_troops_deployed state2.active_players));
  "deployed3" >:: (fun _ -> assert_equal false (all_troops_deployed state_new.active_players));
]

(**)



let suite =
  "Adventure test suite"
  >::: tests

let _ = run_test_tt_main suite
