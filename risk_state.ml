open Command
open Board

type state = {
  num_players: int;
  player_turn: player;
  total_turns: int;
  active_players: player list;
}

let init_state player_num players = {
  num_players = player_num;
  player_turn = List.hd players;
  total_turns = 0;
  active_players = players;
}

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

let trade_in (c: trade_command) (st: state) =
  match c with
  |Same shape -> {st with player_turn = {player_turn with cards = remove_same_cards cards shape 0 []}}
  |Different -> {st with player_turn = {player_turn with cards = remove_different_cards cards [] []}}

let rec find_country country_list target =
  match country_list with
  |[] -> false
  |h::t -> if h.country_id = target then true else find_country t target

let rec update_countries country_list target acc =
  match country_list with
  |[] -> acc
  |h::t -> 

let reinforce (c: reinforce_command) (st: state) =
  if find_country st.player_turn.occupied_countries then
    {st with player_turn = {st.player_turn with
                            num_deployed = st.player_turn.num_deployed + 1;
                            num_undeployed = st.player_turn.num_undeployed - 1;
                           }}
