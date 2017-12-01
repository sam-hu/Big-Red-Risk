open Board
open State

type attack_command = FalseAttack | Attack of (string*string)

type fortify_command = FalseFortify | Fortify of string

type reinforce_command = FalseReinforce | Reinforce of string

type pass_command = unit

(* type card = Circle|Triangle|Square *)

type trade_command = NoTrade | Same of card | Different

let rec attack_helper attacker defender player countries good_attacker good_defender =
  match countries with
  | [] -> if (good_attacker && good_defender) then Attack (attacker, defender) else FalseAttack
  | (c, p, i) :: t -> if (c = attacker && p = player) then attack_helper attacker defender player t true good_defender
    else if (c = defender && p <> player) then attack_helper attacker defender player t good_attacker true
    else attack_helper attacker defender player t good_attacker good_defender

let make_attack_command attacker defender st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  attack_helper attacker defender active_player countries false false

let rec fortify_helper country player country_list =
  match country_list with
  | [] -> FalseFortify
  | (c, p, i)::t -> if (c = country && p = player) then Fortify (country)
    else fortify_helper country player t

let make_fortify_command from_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  fortify_helper from_country active_player countries

let rec reinforce_helper country player country_list =
  match country_list with
  | [] -> FalseReinforce
  | (c, p, i)::t -> if (c = country && p = player) then Reinforce (country)
    else reinforce_helper country player t

let make_reinforce_command to_country st =
  let active_player = st.player_turn.player_id in
  let countries = st.occupied_countries in
  reinforce_helper to_country active_player countries

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
