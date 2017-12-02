open Command
open Board

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

let rec attack_helper attacker defender loser lost player countries good_attacker good_defender =
  match countries with
  | [] -> if (good_attacker && good_defender) then Attack (attacker, defender, loser, lost) else FalseAttack
  | (c, p, i) :: t -> if (c.country_id = attacker && p.player_id = player) then attack_helper attacker defender loser lost player t true good_defender
    else if (c.country_id = defender && p.player_id <> player) then attack_helper attacker defender loser lost player t good_attacker true
    else attack_helper attacker defender loser lost player t good_attacker good_defender

let make_attack_command attacker defender loser lost st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  attack_helper attacker defender loser lost active_player countries false false

let rec fortify_helper country player country_list =
  match country_list with
  | [] -> FalseFortify
  | (c, p, i)::t -> if (c.country_id = country && p.player_id = player) then Fortify (country)
    else fortify_helper country player t

let make_fortify_command from_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  fortify_helper from_country active_player countries

let rec reinforce_helper country player country_list =
  match country_list with
  | [] -> FalseReinforce
  | (c, p, i)::t -> if (c.country_id = country && p.player_id = player) then Reinforce (country)
    else reinforce_helper country player t

let make_reinforce_command to_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  reinforce_helper to_country active_player countries

let rec init_reinforce_helper country country_list =
  match country_list with
  | [] -> Reinforce (country)
  | (c,p,i)::t -> if c.country_id = country then FalseReinforce else
      init_reinforce_helper country t

let init_reinforce_command to_country st =
  init_reinforce_helper to_country st.occupied_countries



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

let p1 = {
  player_id = "Player one";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let p2 = {
  player_id = "Player two";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}

let p3 = {
  player_id = "Player three";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  score = 0;
}
let country1 = {
  country_id = "Country one";
  bordering_countries = []
}

let country2 = {
  country_id = "Country two";
  bordering_countries = []
}

let country3 = {
  country_id = "Country three";
  bordering_countries = []
}

let continent = {
  countries = [country1; country2; country3];
  id = "North America";
  bonus = 5;
}

let board = [continent]

let init_state player_num players = {
  num_players = player_num;
  player_turn = List.hd players;
  total_turns = 0;
  active_players = players;
  reward = 5;
  (* occupied_countries = [(country1, p1, 1);(country2, p2, 1);(country3, p2, 1)]; *)
  occupied_countries = [];
  player_continents = [];
  board = board;
}

let rec num_countries player occupied total =
  match occupied with
  |[] -> total
  |(c,p,i)::t -> if p = player then num_countries player t (total + 1) else
      num_countries player t total

let rec continent_bonus player occupied total =
  match occupied with
  |[] -> total
  |c::t -> continent_bonus player t (total + c.bonus)

let give_troops st =
  let num = (max 3 ((num_countries st.player_turn st.occupied_countries 0)/3)) + continent_bonus st.player_turn st.player_continents 0 in
  {st with player_turn = {st.player_turn with
                          num_undeployed = st.player_turn.num_undeployed + num}}

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
    {st with player_turn =
               {st.player_turn with cards = remove_same_cards st.player_turn.cards shape 0 [];
                                    num_undeployed = st.player_turn.num_undeployed + st.reward};
             reward = st.reward + 5}
  | Different ->
    {st with player_turn =
               {st.player_turn with cards = remove_different_cards st.player_turn.cards [] [];
                                    num_undeployed = st.player_turn.num_undeployed + st.reward};
             reward = st.reward + 5}

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
    ({st with player_turn =
                {st.player_turn with
                 num_deployed = st.player_turn.num_deployed + 1;
                 num_undeployed = st.player_turn.num_undeployed - 1;};
              occupied_countries = update_countries st.occupied_countries c 1 []})


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

let next_player_player st =
 match st.active_players with
  |[] -> failwith "0 players?"
  |h::[] -> h
  |h::h2::[] -> failwith "heres the issue"
    (* if h = st.player_turn then h2 else h *)
  |h::h2::h3::[] -> if h = st.player_turn then h2
    else if h2 = st.player_turn then h3 else h
  |h::h2::h3::h4::[] -> if h = st.player_turn then h2
    else if h2 = st.player_turn then h3 else if
      h3 = st.player_turn then h4 else h
  |_ -> failwith "too many players"

let rec update_player target_player updated_player player_list acc =
  match player_list with
  |[] -> List.rev acc
  |h::t -> if h = target_player then update_player target_player updated_player t (updated_player::acc)
    else update_player target_player updated_player t (h::acc)


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


let pass c st = st

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
      change_possession t origin target player ((c,player,i-1)::acc)
    else
      change_possession t origin target player ((c,p,i)::acc)


let attack cmd (st:state) =
  match cmd with
  | FalseAttack -> st
  | Attack c -> (match c with
      |(l, r, Left, i) -> {st with occupied_countries = update_countries st.occupied_countries l i []}
      |(l, r, Right, i) -> let st' = {st with occupied_countries = update_countries st.occupied_countries r i []} in
        if get_num_troops r st'.occupied_countries = 0 then
          let st'' = {st' with occupied_countries = change_possession st'.occupied_countries l r st'.player_turn []} in
          let country = parse_continent st''.board r in
          let continent = get_continent st''.board r in
          {st'' with player_continents = conquered_continent st'' continent country}
        else st'
      |(l, r, Both, i) -> {st with occupied_countries = update_countries (update_countries st.occupied_countries l i []) r i []})

let rec remove_player st =
  let rec scan lst acc =
    match lst with
    |[] -> acc
    |h::t -> if (num_countries h st.occupied_countries 0) = 0 then scan t acc
      else scan t (h::acc) in scan st.active_players []

let give_card st1 st2 = if num_countries st1.player_turn st1.occupied_countries 0 < num_countries st1.player_turn st2.occupied_countries 0 then
    {st2 with player_turn = {st1.player_turn with
                             cards =
                               if (int_of_float (Sys.time ())) mod 3 = 0 then Circle::(st1.player_turn.cards)
                               else if (int_of_float (Sys.time ())) mod 3 = 1 then Triangle::(st1.player_turn.cards)
                               else Square::(st1.player_turn.cards)}}
  else st2

let fortify cmd st =
  match cmd with
  | FalseFortify -> st
  | Fortify c -> (
      {st with player_turn =
                 {st.player_turn with
                  num_undeployed = st.player_turn.num_undeployed + (get_num_troops c st.occupied_countries) - 1;
                  num_deployed = st.player_turn.num_deployed - (get_num_troops c st.occupied_countries) + 1};
               occupied_countries = update_countries st.occupied_countries c ((get_num_troops c st.occupied_countries) - 1) []})

 let next_player st =
   match st.active_players with
    |[] -> failwith "0 players?"
    |h::[] -> st
    |h::h2::[] -> if h = st.player_turn then {st with player_turn = h2} else
        {st with player_turn = h}
    |h::h2::h3::[] -> if h = st.player_turn then {st with player_turn = h2}
      else if h2 = st.player_turn then {st with player_turn = h3} else
        {st with player_turn = h}
    |h::h2::h3::h4::[] -> if h = st.player_turn then {st with player_turn = h2}
      else if h2 = st.player_turn then {st with player_turn = h3} else if
        h3 = st.player_turn then {st with player_turn = h4} else
        {st with player_turn = h}
    |_ -> failwith "too many players"

let check_if_win st =
  let rec checker occupied target =
    match occupied with
    |[] -> true
    |(c,p,i)::t -> if p = target then checker t target else false
  in checker st.occupied_countries st.player_turn
