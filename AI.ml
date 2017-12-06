open Board
open Risk_state

type ai = player

let rec get_occupied_countries player country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i) :: t -> if (p.player_id = player.player_id)
    then (get_occupied_countries player t ((c, p, i)::acc))
    else get_occupied_countries player t acc

let rec go_to_element element_list i_random acc =
  match element_list with
  | [] -> failwith "out of continents"
  | h::t -> if (acc = i_random) then h else go_to_element t i_random (acc+1)

let get_random_continent st =
  Random.init (int_of_float (Unix.time ()));
  let random = Random.int 5 in
  go_to_element st.board random 0

let rec is_unoccupied_continent occupied_countries continent =
  match occupied_countries with
  | [] -> true
  | (c, p, i)::t -> if (List.mem c continent.countries) then false else is_unoccupied_continent t continent

let rec all_continents_occupied st continent_list =
  match continent_list with
  | [] -> true
  | h::t -> if (is_unoccupied_continent st.occupied_countries h) then false else all_continents_occupied st t

let rec get_unoccupied_continent st continent_list =
  let continent = get_random_continent st in
  if (is_unoccupied_continent st.occupied_countries continent) then continent
  else get_unoccupied_continent st continent_list

let get_random_country_in_continent continent =
  Random.init (int_of_float (Unix.time ()));
  let random = Random.int (List.length (continent.countries)) in
  go_to_element continent.countries random 0

let rec get_all_occupied_countries country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i)::t -> get_all_occupied_countries t (c::acc)

let rec get_unoccupied_countries occupied_countries all_countries =
  (* match all_countries with
  | [] -> acc
  | h::t -> if (List.mem h occupied_countries)
    then get_unoccupied_countries t all_countries (acc)
     else get_unoccupied_countries t all_countries (h::acc) *)
  List.filter (fun x -> not (List.mem x occupied_countries)) all_countries

let all_countries st = get_all_countries st.board []

let get_random_unoccupied_country st =
  Random.init (int_of_float (Unix.time ()));
  let all_occupied_countries = get_all_occupied_countries st.occupied_countries [] in
  let all_unoccupied_countries = get_unoccupied_countries all_occupied_countries (all_countries st) in
  let random = Random.int (List.length (all_unoccupied_countries)) in
  go_to_element all_unoccupied_countries random 0

let ai_next_initial_reinforce st =
  if (all_continents_occupied st st.board)
  then ((get_random_unoccupied_country st).country_id) (*get random unoccupied country*)
  else (let random_continent = get_unoccupied_continent st st.board in
        let random_country = get_random_country_in_continent random_continent in
        random_country.country_id)

(*returns true if country is an enemy country of current_player*)
let rec is_enemy_country country current_player country_list =
  match country_list with
  | [] -> failwith "country is not in country list"
  | (c, p, i)::t -> if c.country_id = country.country_id
    then p.player_id <> current_player.player_id
    else is_enemy_country country current_player t

(*returns the sum of the number of troops in enemy bordering countries of [country]*)
let rec get_sum_troops_in_bordering_countries occupied_countries current_player country acc =
  match occupied_countries with
  | [] -> acc
  | (c, p, i)::t -> if (List.mem c.country_id country.bordering_countries && is_enemy_country c current_player occupied_countries)
    then (get_sum_troops_in_bordering_countries t current_player country (i+acc))
    else (get_sum_troops_in_bordering_countries t current_player country (acc))

(*returns a tuple list of each country in in country_list bound to the difference between the number of troops in that
  country and the sum of the number of troops in that country's bordering countries*)
let rec countries_and_enemies_difference st country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i)::t -> (countries_and_enemies_difference st t ((c, (get_sum_troops_in_bordering_countries st.occupied_countries st.player_turn c 0)-i)::acc))

let rec country_to_reinforce country_differences acc =
  match country_differences with
  | [] -> acc
  | (c, i)::t -> if i > (snd acc) then country_to_reinforce t (c,i)
    else country_to_reinforce t acc

let rec ai_next_reinforce st =
  let occupied_countries = get_occupied_countries st.player_turn st.occupied_countries [] in
  let countries_and_enemies_difference_list = countries_and_enemies_difference st occupied_countries [] in
  let next_country = country_to_reinforce countries_and_enemies_difference_list (List.hd countries_and_enemies_difference_list) |> fst in
  next_country.country_id

(*returns a tuple of [country], each enemy bordering country of [country], and the ratio between the number of troops
  in [country] and that bordering country*)
let rec get_bordering_countries_with_ratio occupied_countries current_player (country:(country*player*int)) acc =
  match occupied_countries, country with
  | [], _ -> acc
  | (c, p, i)::t, (c0,p0,i0) -> if (List.mem c.country_id c0.bordering_countries && is_enemy_country c current_player occupied_countries)
    then get_bordering_countries_with_ratio t current_player country ((c0, c, (float_of_int i0) /. (float_of_int i))::acc)
    else get_bordering_countries_with_ratio t current_player country (acc)

let rec countries_and_enemies_ratio st country_list acc =
  match country_list with
  | [] -> acc
  | h::t -> countries_and_enemies_ratio st t ((get_bordering_countries_with_ratio st.occupied_countries st.player_turn h []) @ acc)

let rec country_to_attack country_ratios acc =
  match country_ratios with
  | [] -> acc (* is ("none", "none") by default*)
  | (c_a, c_d, ratio)::t -> if (ratio > 1.2) then (c_a.country_id, c_d.country_id)
    else country_to_attack t acc

let rec ai_next_attack st : (string*string)=
  let occupied_countries = get_occupied_countries st.player_turn st.occupied_countries [] in
  let possible_attacks = countries_and_enemies_ratio st occupied_countries [] in
  let next_country = country_to_attack possible_attacks ("none", "none") in
  print_endline ((fst next_country) ^ " " ^ (snd next_country)); next_country

let ai_next_reinforce_after_attack st country_id1 country_id2 =
  let country1 = get_country_assured (all_countries st) country_id1 in
  let country2 = get_country_assured (all_countries st) country_id2 in
  let country1_troops = get_num_troops country1.country_id st.occupied_countries in
  let country2_troops = get_num_troops country2.country_id st.occupied_countries in
  if (get_sum_troops_in_bordering_countries st.occupied_countries st.player_turn country1 0 - country1_troops
      > get_sum_troops_in_bordering_countries st.occupied_countries st.player_turn country2 0 - country2_troops)
  then country1.country_id else country2.country_id

(*returns true if [country] has no enemy bordering countries, false otherwise*)
let rec is_interior_country occupied_countries current_player country =
  match occupied_countries with
  | [] -> true
  | (c, p, i)::t -> if (List.mem c.country_id country.bordering_countries && (is_enemy_country c current_player occupied_countries))
    then false else is_interior_country t current_player country

let rec get_interior_countries occupied_countries current_player acc =
  match occupied_countries with
  | [] -> acc
  | (c, p, i)::t -> if (is_interior_country occupied_countries current_player c) then get_interior_countries t current_player ((c.country_id, i)::acc)
    else get_interior_countries t current_player (acc)

let rec country_to_fortify_from interior_countries acc =
  match interior_countries with
  | [] -> acc (* is ("none", 0) by default *)
  | (c, i)::t -> if (i>snd acc) then country_to_fortify_from t (c, i)
    else country_to_fortify_from t acc

let rec ai_next_fortify st =
  let occupied_countries = get_occupied_countries st.player_turn st.occupied_countries [] in
  let interior_countries = get_interior_countries occupied_countries st.player_turn [] in
  let next_country = country_to_fortify_from interior_countries ("none", 0) in
  fst next_country
