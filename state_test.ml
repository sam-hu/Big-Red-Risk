open OUnit2
open Risk_state
open Command
open Board

let p1 = {
  player_id = "player 1";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let p2 = {
  player_id = "player 2";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let p3 = {
  player_id = "player 3";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let p4 = {
  player_id = "player 4";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let players = [p1;p2;p3;p4]

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
  occupied_continents = [];
  board = board;
}

let state2 = {
  num_players = 4;
  player_turn = p2;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  occupied_continents = [];
  board = board;
}

let state3 = {
  num_players = 4;
  player_turn = p3;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  occupied_continents = [];
  board = board;
}

let state4 = {
  num_players = 4;
  player_turn = p4;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [];
  occupied_continents = [];
  board = board;
}

let before_attack = {
  num_players = 4;
  player_turn = p1;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [(country1, p1, 3);(country2, p2, 4);(country3, p3, 2)];
  occupied_continents = [];
  board = board;
}

let after_attack = {
  num_players = 4;
  player_turn = p1;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [(country1, p1, 2);(country2, p1, 1);(country3, p3, 2)];
  occupied_continents = [];
  board = board;
}

let reinforced_one = {
  num_players = 4;
  player_turn = p1;
  total_turns = 0;
  active_players = players;
  reward = 5;
  occupied_countries = [(country1, p1, 1)];
  occupied_continents = [];
  board = board;
}

let attack_command = Attack ("USA","Canada",Right,-4)

let reinforce_begin_command = Reinforce "USA"

let reinforce_begin_command2 = Reinforce "Cuba"

let tests =[
  "init_state" >:: (fun _ -> assert_equal state (init_state 4 players));
  "next player" >:: (fun _ -> assert_equal state (state |> next_player |> next_player |> next_player |> next_player));
  "next player2" >:: (fun _ -> assert_equal state2 (state |> next_player));
  "next player3" >:: (fun _ -> assert_equal state3 (init_state 4 players |> next_player |> next_player));
  "attack 1" >:: (fun _ -> assert_equal after_attack (attack attack_command before_attack));
  "reinforce first" >:: (fun _ -> assert_equal reinforced_one (init_state 4 players |> reinforce_begin reinforce_begin_command))


  (* tests init_state function to see if all values are initialized properly for "threeroom.json"*)
  (* "1: max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> win_score));
  "1: start_score" >:: (fun _ -> assert_equal 10001 (j |> init_state |> score));
  "1: start_turns" >:: (fun _ -> assert_equal 0 (j |> init_state |> turns));
  "1: start_room" >:: (fun _ -> assert_equal "room1" (j |> init_state |> current_room_id));
  "1: start_inv" >:: (fun _ -> assert_equal ["white hat"] (j |> init_state |> inv));
  "1: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j |> init_state |> visited));
  "1: start_locations" >:: (fun _ -> assert_equal [("room2", "key");
                                                ("room1", "red hat");
                                                ("room1", "black hat")]
                            (j |> init_state |> locations));

  (* tests init_state function to see if all values are initialized properly for "oneroom.json"*)
  "2: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> win_score));
  "2: start_score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> score));
  "2: start_turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> turns));
  "2: start_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> current_room_id));
  "2: start_inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> inv));
  "2: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> visited));
  "2: start_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> locations));

  (* tests init_state function to see if all values are initialized properly for "GameOfThronesAdventure.json"*)
  "3: max" >:: (fun _ -> assert_equal 72650 (gotj |> init_state |> win_score));
  "3: start_score" >:: (fun _ -> assert_equal 0 (gotj |> init_state |> score));
  "3: start_turns" >:: (fun _ -> assert_equal 0 (gotj |> init_state |> turns));
  "3: start_room" >:: (fun _ -> assert_equal "winterfell" (gotj |> init_state |> current_room_id));
  "3: start_inv" >:: (fun _ -> assert_equal [] (gotj |> init_state |> inv));
  "3: rooms_visited" >:: (fun _ -> assert_equal ["winterfell"] (gotj |> init_state |> visited));
  "3: start_locations" >:: (fun _ ->
      assert_equal [("kings landing", "ned stark"); ("casterly rock", "food");
                    ("casterly rock", "army"); ("wendish town", "treasure map");
                    ("iron islands", "water"); ("iron islands", "theon grayjoy");
                    ("stony shore", "gold"); ("stony shore", "warriors");
                    ("castle black", "john snow"); ("winterfell", "whitewalker scroll");
                    ("winterfell", "sword")] (gotj |> init_state |> locations));

  (* tests the effects of the quit commmand on "oneroom.json"*)
  "4: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' quitCommand |> win_score));
  "4: score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' quitCommand |> score));
  "4: turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> do' quitCommand |> turns));
  "4: current_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> do' quitCommand |> current_room_id));
  "4: inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> do' quitCommand |> inv));
  "4: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> do' quitCommand |> visited));
  "4: item_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> do' quitCommand |> locations));

  (* tests the effects of the look commmand on "oneroom.json"*)
  "5: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' lookCommand |> win_score));
  "5: score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' lookCommand |> score));
  "5: turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> do' lookCommand |> turns));
  "5: current_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> do' lookCommand |> current_room_id));
  "5: inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> do' lookCommand |> inv));
  "5: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> do' lookCommand |> visited));
  "5: item_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> do' lookCommand |> locations));

  (* tests the effects of the score commmand on "oneroom.json"*)
  "5b: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' scoreCommand |> win_score));
  "5b: score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' scoreCommand |> score));
  "5b: turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> do' scoreCommand |> turns));
  "5b: current_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> do' scoreCommand |> current_room_id));
  "5b: inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> do' scoreCommand |> inv));
  "5b: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> do' scoreCommand |> visited));
  "5b: item_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> do' scoreCommand |> locations));

  (* tests the effects of the turns commmand on "oneroom.json"*)
  "5c: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' turnsCommand |> win_score));
  "5c: score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' turnsCommand |> score));
  "5c: turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> do' turnsCommand |> turns));
  "5c: current_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> do' turnsCommand |> current_room_id));
  "5c: inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> do' turnsCommand |> inv));
  "5c: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> do' turnsCommand |> visited));
  "5c: item_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> do' turnsCommand |> locations));

  (* tests the effects of an invalid command on "oneroom.json"*)
  "5d: max" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' invalidCommand |> win_score));
  "5d: score" >:: (fun _ -> assert_equal 110 (j2 |> init_state |> do' invalidCommand |> score));
  "5d: turns" >:: (fun _ -> assert_equal 0 (j2 |> init_state |> do' invalidCommand |> turns));
  "5d: current_room" >:: (fun _ -> assert_equal "room1" (j2 |> init_state |> do' invalidCommand |> current_room_id));
  "5d: inv" >:: (fun _ -> assert_equal [] (j2 |> init_state |> do' invalidCommand |> inv));
  "5d: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j2 |> init_state |> do' invalidCommand |> visited));
  "5d: item_locations" >:: (fun _ -> assert_equal [("room1", "item1")] (j2 |> init_state |> do' invalidCommand |> locations));

  (* tests the effects of the inv commmand on "threerooms.json"*)
  "6: max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> do' invCommand |> win_score));
  "6: score" >:: (fun _ -> assert_equal 10001 (j |> init_state |> do' invCommand |> score));
  "6: turns" >:: (fun _ -> assert_equal 0 (j |> init_state |> do' invCommand |> turns));
  "6: current_room" >:: (fun _ -> assert_equal "room1" (j |> init_state |> do' invCommand |> current_room_id));
  "6: inv" >:: (fun _ -> assert_equal ["white hat"] (j |> init_state |> do' invCommand |> inv));
  "6: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j |> init_state |> do' invCommand |> visited));
  "6: item_locations" >:: (fun _ -> assert_equal [("room2", "key");
                                                ("room1", "red hat");
                                                ("room1", "black hat")]
                               (j |> init_state |> do' invCommand |> locations));

  (* tests the effects of "take black hat" commmand on "threerooms.json"*)
  "7: max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> do' takeCommand |> win_score));
  "7: score" >:: (fun _ -> assert_equal 10001 (j |> init_state |> do' takeCommand |> score));
  "7: turns" >:: (fun _ -> assert_equal 1 (j |> init_state |> do' takeCommand |> turns));
  "7: current_room" >:: (fun _ -> assert_equal "room1" (j |> init_state |> do' takeCommand |> current_room_id));
  "7: inv" >:: (fun _ -> assert_equal ["white hat";"black hat"] (j |> init_state |> do' takeCommand |> inv));
  "7: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j |> init_state |> do' takeCommand |> visited));
  "7: item_locations" >:: (fun _ -> assert_equal [("room2", "key");
                                                ("room1", "red hat");]
                              (j |> init_state |> do' takeCommand |> locations));

  (* tests the effects of "drop white hat" commmand on "threerooms.json"*)
  "8: max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> do' dropCommand |> win_score));
  "8: score" >:: (fun _ -> assert_equal 11001 (j |> init_state |> do' dropCommand |> score));
  "8: turns" >:: (fun _ -> assert_equal 1 (j |> init_state |> do' dropCommand |> turns));
  "8: current_room" >:: (fun _ -> assert_equal "room1" (j |> init_state |> do' dropCommand |> current_room_id));
  "8: inv" >:: (fun _ -> assert_equal [] (j |> init_state |> do' dropCommand |> inv));
  "8: rooms_visited" >:: (fun _ -> assert_equal ["room1"] (j |> init_state |> do' dropCommand |> visited));
  "8: item_locations" >:: (fun _ -> assert_equal [("room2", "key");
                                                ("room1", "red hat");
                                                  ("room1", "black hat");
                                                 ("room1","white hat")]
                              (j |> init_state |> do' dropCommand |> locations));

  (* tests the effects of "go room2" commmand on "threerooms.json"*)
  "9: max" >:: (fun _ -> assert_equal 11111 (j |> init_state |> do' goCommand |> win_score));
  "9: score" >:: (fun _ -> assert_equal 10011 (j |> init_state |> do' goCommand |> score));
  "9: turns" >:: (fun _ -> assert_equal 1 (j |> init_state |> do' goCommand |> turns));
  "9: current_room" >:: (fun _ -> assert_equal "room2" (j |> init_state |> do' goCommand |> current_room_id));
  "9: inv" >:: (fun _ -> assert_equal ["white hat"] (j |> init_state |> do' goCommand |> inv));
  "9: rooms_visited" >:: (fun _ -> assert_equal ["room2";"room1"] (j |> init_state |> do' goCommand |> visited));
  "9: item_locations" >:: (fun _ -> assert_equal [("room2", "key");
                                                ("room1", "red hat");
                                                ("room1", "black hat")]
                              (j |> init_state |> do' goCommand |> locations));*)
]

let suite =
  "Adventure test suite"
  >::: tests

let _ = run_test_tt_main suite
