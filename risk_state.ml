open Command
open Board
open Unix

(* type [state] is the representation of every aspect of the game state *)
type state = {
  num_players: int;
  player_turn: player;
  total_turns: int;
  active_players: player list;
  reward: int;
  occupied_countries: (country*player*int) list;
  player_continents: continent list;
  board: board;
}
(*************************************)

let print_player player =
  Pervasives.print_endline player.player_id;
  Pervasives.print_int player.num_deployed;
  Pervasives.print_int player.num_undeployed;
  Pervasives.print_int (List.length player.cards);
  Pervasives.print_int player.score;
  Pervasives.print_endline ""

(* Returns: true if [player] owns the country identified by [country_string]
   in [occupied_list], false otherwise *)
let rec owns_country country_string occupied_list player =
  match occupied_list with
  |[] -> false
  |(c,p,i)::t ->
    if (player = p && c.country_id = country_string) then true
    else owns_country country_string t player

(* returns the country in [country_list] with country_id [target]
 * Precondition: [target] is in country_list *)
let rec get_country_assured country_list target =
  match country_list with
  |[] -> failwith "Precondition violated"
  |h::t -> if h.country_id = target then h else get_country_assured t target

(* returns a list of all countries in [continent_list] *)
let rec get_all_countries continent_list acc =
  match continent_list with
  |[] -> acc
  |h::t -> get_all_countries t (h.countries @ acc)

(* returns Attack command if [attacker] and [defender] are valid in the
   game, FalseAttack otherwise *)
let rec attack_helper attacker defender loser lost player countries good_attacker good_defender =
  match countries with
  | [] -> if (good_attacker && good_defender) then Attack (attacker, defender, loser, lost) else FalseAttack
  | (c, p, i) :: t -> if (c.country_id = attacker && p.player_id = player) then attack_helper attacker defender loser lost player t true good_defender
    else if (c.country_id = defender && p.player_id <> player) then attack_helper attacker defender loser lost player t good_attacker true
    else attack_helper attacker defender loser lost player t good_attacker good_defender

(* returns Attack command if [attacker] and [defender] are valid in the game
   FalseAttack otherwise *)
let make_attack_command attacker defender loser lost st =
  let attacking_country = get_country_assured (get_all_countries st.board []) attacker in
  let defending_country = get_country_assured (get_all_countries st.board []) defender in
  if List.mem attacker defending_country.bordering_countries && List.mem defender attacking_country.bordering_countries then
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  attack_helper attacker defender loser lost active_player countries false false
  else FalseAttack

(* returns Fortify command if [player] owns [country] in [country_list] and has
   more than one troop in that country, FalseFortify otherwise *)
let rec fortify_helper country player country_list =
  match country_list with
  | [] -> FalseFortify
  | (c, p, i)::t -> if (c.country_id = country && p.player_id = player && i > 1) then Fortify (country)
    else fortify_helper country player t

(* returns Fortify command if [from_country] is a valid country to fortify from,
   FalseFortify otherwise *)
let make_fortify_command from_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  fortify_helper from_country active_player countries

(* returns Reinforce command if [player] owns [country], FalseReinforce
   otherwise *)
let rec reinforce_helper country player country_list =
  match country_list with
  | [] -> FalseReinforce
  | (c, p, i)::t -> if (c.country_id = country && p.player_id = player) then Reinforce (country)
    else reinforce_helper country player t

(* returns Reinforce command if [to_country] is valid, FalseReinforce otherwise
 *)
let make_reinforce_command to_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  reinforce_helper to_country active_player countries

(* returns Reinforce command if [country] is not in [country_list],
   FalseReinforce otherwise *)
let rec init_reinforce_helper country country_list =
  match country_list with
  | [] -> Reinforce (country)
  | (c,p,i)::t -> if c.country_id = country then FalseReinforce else
      init_reinforce_helper country t

(* returns Reinforce command if [to_country] is a valid country,
   FalseReinforce otherwise*)
let init_reinforce_command to_country st =
  init_reinforce_helper to_country st.occupied_countries

let rec all_troops_deployed players =
  match players with
  | [] -> true
  | h::t -> if (h.num_undeployed > 0) then false else all_troops_deployed t

let make_pass_command = ()

let rec three_same card_list circles triangles squares =
  if (circles = 3) then (true, Circle)
  else if (triangles = 3) then (true,Triangle)
  else if (squares = 3) then (true, Square)
  else
    (match card_list with
     | [] -> (false, Circle)
     | Circle::t -> three_same t (circles+1) triangles squares
     | Triangle::t -> three_same t circles (triangles+1) squares
     | Square::t -> three_same t circles triangles (squares+1))

let rec three_diff card_list circles triangles squares =
  if (circles > 0 && triangles > 0 && squares > 0) then true else
    (match card_list with
     | [] -> false
     | Circle::t -> three_diff t (circles+1) triangles squares
     | Triangle::t -> three_diff t circles (triangles+1) squares
     | Square::t -> three_diff t circles triangles (squares+1))

let make_trade_command st =
  let cards = st.player_turn.cards in
  let same = three_same cards 0 0 0 in
  let diff = three_diff cards 0 0 0 in
  if (fst same) then Same (snd same)
  else if (diff) then Different
  else NoTrade


let init_state player_num players brd = {
  num_players = player_num;
  player_turn = List.hd players;
  total_turns = 0;
  active_players = players;
  reward = 5;
  (* occupied_countries = [(country1, p1, 1);(country2, p2, 1);(country3, p2, 1)]; *)
  occupied_countries = [];
  player_continents = [];
  board = brd;
}

let rec change_player occupied_list new_player acc =
  match occupied_list with
  |[] -> acc
  |(c,p,i)::t -> if p.player_id = new_player.player_id then
      change_player t new_player ((c,new_player,i)::acc) else
      change_player t new_player ((c,p,i)::acc)

let next_player_player st =
  match st.active_players with
  |[] -> failwith "0 players?"
  |h::[] -> h
  |h::h2::[] -> if h = st.player_turn then h2 else h
  (* if h = st.player_turn then h2 else h *)
  |h::h2::h3::[] -> if h = st.player_turn then h2
    else if h2 = st.player_turn then h3 else h
  |h::h2::h3::h4::[] -> if h = st.player_turn then h2
    else if h2 = st.player_turn then h3 else if
      h3 = st.player_turn then h4 else h
  |_ -> failwith "too many players"

let rec update_player target_player updated_player player_list acc =
  match player_list with
  |[] -> (List.rev acc)
  |h::t ->
    if h = target_player then (
      update_player target_player updated_player t (updated_player::acc))
    else update_player target_player updated_player t (h::acc)

let rec num_countries player occupied total =
  match occupied with
  |[] -> total
  |(c,p,i)::t -> if p = player then num_countries player t (total + 1) else
      num_countries player t total

let rec continent_bonus occupied total =
  match occupied with
  |[] -> total
  |c::t -> continent_bonus t (total + c.bonus)

let give_troops st =
  let num = (max 3 ((num_countries st.player_turn st.occupied_countries 0)/3)) + continent_bonus st.player_continents 0 in
  let st' = {st with player_turn = {st.player_turn with
                                    num_undeployed = st.player_turn.num_undeployed + num}} in
  {st' with active_players = update_player st.player_turn st'.player_turn st.active_players [];
            occupied_countries = change_player st'.occupied_countries st'.player_turn []}



let rec remove_same_cards card_list target num_removed card_accum =
  if num_removed < 3 then
    match card_list with
    |[] -> failwith "Whyyyyyy"
    |h::t -> if h = target then
        remove_same_cards t target (num_removed + 1) card_accum else
        remove_same_cards t target num_removed (h::card_accum)
  else card_accum @ card_list

let rec remove_different_cards card_list removed card_accum =
  if List.length removed < 3 then
    match card_list with
    |[] -> failwith "wrong"
    |h::t-> if List.mem h removed then remove_different_cards t removed (h::card_accum)
      else remove_different_cards t (h::removed) card_accum
  else card_accum @ card_list

let trade_in (cmd: trade_command) (st: state) =
  match cmd with
  | NoTrade -> st
  | Same shape ->
    ( let st' = {st with player_turn =
                          {st.player_turn with cards = remove_same_cards st.player_turn.cards shape 0 [];
                                               num_undeployed = st.player_turn.num_undeployed + st.reward};
                        reward = st.reward + 5} in
      {st' with active_players = update_player st.player_turn st'.player_turn st'.active_players [];
                occupied_countries = change_player st'.occupied_countries st'.player_turn []})
  | Different ->
    (let st' = {st with player_turn =
                          {st.player_turn with cards = remove_different_cards st.player_turn.cards [] [];
                                              num_undeployed = st.player_turn.num_undeployed + st.reward};
                       reward = st.reward + 5} in
     {st' with active_players = update_player st.player_turn st'.player_turn st'.active_players []})


let rec update_countries occupied_list target delta acc =
  match occupied_list with
  |[] -> acc
  |(c, p, i)::t -> if c.country_id = target then
      update_countries t target delta ((c,p,i+delta)::acc) else
      update_countries t target delta ((c,p,i)::acc)

let reinforce (cmd: reinforce_command) (st: state) =
  match cmd with
  | FalseReinforce -> st
  | Reinforce c ->
     let st' = {st with player_turn =
                         {st.player_turn with
                          num_deployed = st.player_turn.num_deployed + 1;
                          num_undeployed = st.player_turn.num_undeployed - 1};
                       occupied_countries = update_countries st.occupied_countries c 1 []} in
     {st' with active_players = update_player st.player_turn st'.player_turn st'.active_players [];
               occupied_countries = change_player st'.occupied_countries st'.player_turn []}


let rec get_country country_list target =
  match country_list with
  |[] -> None
  |h::t -> if h.country_id = target then Some h else get_country t target

let rec parse_continent continent_list target =
  match continent_list with
  |[] -> failwith "Country DNE1"
  |h::t ->
    match get_country h.countries target with
    |None -> parse_continent t target
    |Some x -> x

let rec get_continent continent_list target =
  match continent_list with
  |[] -> failwith "Country DNE2"
  |h::t ->
    match get_country h.countries target with
    |None -> get_continent t target
    |Some x -> h

(* [compare_continent continent country_list] returns true if every country in
   [continent] is in the player's [country_list], false otherwise *)
let rec compare_continent continent country_list =
  match continent with
  |[] -> true
  |h::t -> if List.mem h country_list then compare_continent t country_list
    else false

(* Return a list of all the countries occupied by [player] *)
let rec player_countries lst player acc =
  match lst with
  |[] -> acc
  |(c,p,i)::t -> if p = player then player_countries t player (c::acc)
    else player_countries t player acc

let build_continent_list st =
  let owned_countries = player_countries st.occupied_countries st.player_turn [] in
  let rec builder continent_list acc = (*matches against board, acc1 is player occupied continents list*)
    match continent_list with
    |[] -> acc
    |cont::t -> if (compare_continent cont.countries owned_countries) then builder t (cont::acc)
      else builder t (acc) in {st with player_continents = builder st.board []} (*see if player has all countries in [continent]*)


let rec conquered_continent st continent country =
  if List.mem continent st.player_continents then
    st.player_continents else
    (let countries = player_countries st.occupied_countries st.player_turn [] in
     if compare_continent continent.countries countries then continent::st.player_continents
     else st.player_continents)


let reinforce_begin cmd st =
  match cmd with
  | FalseReinforce -> st
  | Reinforce c ->
    let country = parse_continent st.board c in
    let player_updated = {st.player_turn with
                          num_deployed = st.player_turn.num_deployed + 1;
                          num_undeployed = st.player_turn.num_undeployed - 1} in
    {st with player_turn = next_player_player st;
             occupied_countries = (country, st.player_turn, 1)::st.occupied_countries;
             active_players = update_player st.player_turn player_updated st.active_players []}


let rec get_num_troops target country_list =
  match country_list with
  |[] -> failwith "get_num_troops error"
  |(c, p, i)::t -> if c.country_id = target then i else get_num_troops target t

let rec change_possession occupied_list origin target player acc =
  match occupied_list with
  |[] -> acc
  |(c, p, i)::t -> if c.country_id = target then
      change_possession t origin target player ((c,player,1)::acc)
    else if c.country_id = origin then
      change_possession t origin target player ((c,player,1)::acc)
    else
      change_possession t origin target player ((c,p,i)::acc)

let rec get_player_from_country occupied_list target_country =
  match occupied_list with
  |[] -> failwith "This country is nonexistent"
  |(c,p,i)::t -> if c.country_id = target_country then p else
      get_player_from_country t target_country

let rec get_player target_player player_list =
  match player_list with
  |[] -> failwith "Player doesnt exits"
  |h::t -> if h.player_id = target_player.player_id then h else
      get_player target_player t

let rec total_deployed player occupied total =
  match occupied with
  |[] -> {player with num_deployed = total}
  |(c,p,i)::t -> if p.player_id = player.player_id then total_deployed player t (total + i) else
      total_deployed player t total

let rec update_deployed player_list target_state acc =
  match player_list with
  |[] -> {target_state with active_players = List.rev acc}
  |h::t -> update_deployed t target_state ((total_deployed h target_state.occupied_countries 0)::acc)

let attack cmd (st:state) =
  match cmd with
  | FalseAttack -> st
  | Attack c -> (match c with
      |(l, r, Left, i) ->
        let st' = {st with occupied_countries = update_countries st.occupied_countries l i [];
                           player_turn = {st.player_turn with
                                         num_deployed = st.player_turn.num_deployed + i}} in
        {st' with active_players = update_player st.player_turn st'.player_turn st.active_players [];
                  occupied_countries = change_player st'.occupied_countries st'.player_turn []}
      |(l, r, Right, i) ->
        let st1 = {st with occupied_countries = update_countries st.occupied_countries r i []} in
        let st2 = update_deployed st1.active_players st1 [] in
        let st' = {st2 with occupied_countries = change_player st2.occupied_countries (get_player (get_player_from_country st2.occupied_countries r) st2.active_players) []} in
        let st66 = update_deployed st'.active_players st' [] in
        if get_num_troops r st66.occupied_countries = 0 then
          let st'' = {st66 with occupied_countries = change_possession st66.occupied_countries l r st66.player_turn [];
                                player_turn = {st66.player_turn with
                                               num_deployed = st66.player_turn.num_deployed - (get_num_troops l st66.occupied_countries) + 2;
                                               num_undeployed = st66.player_turn.num_undeployed + (get_num_troops l st66.occupied_countries) - 2}} in
          let st3 = {st'' with occupied_countries = change_player st''.occupied_countries st''.player_turn [];
                               active_players = update_player st66.player_turn st''.player_turn st66.active_players []} in
          let country = parse_continent st''.board r in
          let continent = get_continent st''.board r in
          {st3 with player_continents = conquered_continent st'' continent country}
        else st66
      |(l, r, Both, i) ->
        (let st' = {st with occupied_countries = update_countries st.occupied_countries l i [];
                            player_turn = {st.player_turn with
                                          num_deployed = st.player_turn.num_deployed + i}} in
         let st2 = {st' with active_players = update_player st.player_turn st'.player_turn st.active_players [];
                             occupied_countries = change_player st'.occupied_countries st'.player_turn []} in
         let st3 = {st2 with occupied_countries = update_countries st2.occupied_countries r i []} in
         let st4 = update_deployed st3.active_players st3 [] in
         {st4 with occupied_countries = change_player st4.occupied_countries (get_player (get_player_from_country st4.occupied_countries r) st4.active_players) []}))

let rec remove_player st =
  let rec scan lst acc =
    match lst with
    |[] -> acc
    |h::t -> if (num_countries h st.occupied_countries 0) = 0 then scan t acc
      else (scan t (h::acc)) in let new_players = (scan st.active_players []) |> List.rev in
  {st with active_players = new_players}

let give_card st1 st2 = if num_countries st1.player_turn st1.occupied_countries 0 < num_countries st2.player_turn st2.occupied_countries 0 then
    let ran_var = int_of_float (Unix.time ()) in
    let st = {st2 with player_turn = {st2.player_turn with
                                      cards =
                                        if ran_var mod 3 = 0 then (Pervasives.print_endline "Circle"; Circle::(st2.player_turn.cards))
                                        else if ran_var mod 3 = 1 then (Pervasives.print_endline "Triangle"; Triangle::(st2.player_turn.cards))
                                        else if ran_var mod 3 = 2 then (Pervasives.print_endline "Square"; Square::(st2.player_turn.cards))
                                        else failwith "Booo"}} in
     {st with active_players = update_player st2.player_turn st.player_turn st2.active_players [];
              occupied_countries = change_player st.occupied_countries st.player_turn []}
  else st2

let fortify cmd st =
  match cmd with
  | FalseFortify -> st
  | Fortify c -> (
      let st' = {st with player_turn =
                 {st.player_turn with
                  num_undeployed = st.player_turn.num_undeployed + (get_num_troops c st.occupied_countries) - 1;
                  num_deployed = st.player_turn.num_deployed - (get_num_troops c st.occupied_countries) + 1};
                         occupied_countries = update_countries st.occupied_countries c (-(get_num_troops c st.occupied_countries) + 1) []} in
      {st' with active_players = update_player st.player_turn st'.player_turn st.active_players [];
                occupied_countries = change_player st'.occupied_countries st'.player_turn []})

 let next_player st =
   match st.active_players with
    |[] -> failwith "0 players?"
    |h::[] -> st
    |h::h2::[] -> if h = st.player_turn then {st with player_turn = h2} else
        {st with player_turn = h;
        total_turns = st.total_turns + 1}
    |h::h2::h3::[] -> if h = st.player_turn then {st with player_turn = h2}
      else if h2 = st.player_turn then {st with player_turn = h3} else
        {st with player_turn = h;
        total_turns = st.total_turns + 1}
    |h::h2::h3::h4::[] -> if h = st.player_turn then {st with player_turn = h2}
      else if h2 = st.player_turn then {st with player_turn = h3} else if
        h3 = st.player_turn then {st with player_turn = h4} else
        {st with player_turn = h;
        total_turns = st.total_turns + 1}
    |_ -> failwith "too many players"

let check_if_win st =
  let rec checker occupied target =
    match occupied with
    |[] -> true
    |(c,p,i)::t -> if p = target then checker t target else false
  in checker st.occupied_countries st.player_turn

let rec num_continents occupied total =
  match occupied with
  |[] -> total
  |c::t -> continent_bonus t (total + 1)

let rec update_individual_score st =
  let st' = build_continent_list st in
  let st2 = {st with player_turn = {st'.player_turn with
                                    score = num_countries st'.player_turn st'.occupied_countries 0 + num_continents st'.player_continents 0}} in
  {st2 with active_players = update_player st.player_turn st2.player_turn st.active_players [];
            occupied_countries = change_player st2.occupied_countries st2.player_turn []}

let update_scores st =
  let st2 = update_individual_score st in
  let st3 = next_player st2 in
  if st3.player_turn = st.player_turn then st3 else
  let st4 = update_individual_score st3 in
  let st5 = next_player st4 in
  if st5.player_turn = st.player_turn then st5 else
  let st6 = update_individual_score st5 in
  let st7 = next_player st6 in
  if st7.player_turn = st.player_turn then st7 else
  let st8 = update_individual_score st7 in
  next_player st8
