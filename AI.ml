open Board
open Risk_state

type ai = player

let ai1 = {
  player_id = "Player one";
  num_deployed = 0;
  num_undeployed= 0;
  cards = [];
  ai = true;
  ratio = 0.0
}

let ai2 = {
  player_id = "Player two";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = true;
  ratio = 0.0
}

let ai3 = {
  player_id = "Player three";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = true;
  ratio = 0.0
}

let ai4 = {
  player_id = "Player four";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = true;
  ratio = 0.0
}

(*[all_countries st] returns a list of all countries in [st.board] *)
let all_countries st = get_all_countries st.board []

(*[all_countries st] returns a list of all countries in [st.board] occupied by
  [player] bound to the number of troops in that country *)
let rec get_my_countries player country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i) :: t -> if (p.player_id = player.player_id)
    then (get_my_countries player t ((c, p, i)::acc))
    else get_my_countries player t acc

(*[get_random_continent st] returns a random continent in [st.board] *)
let get_random_continent st =
  Random.init (int_of_float (Unix.time ()));
  let random = Random.int (List.length st.board) in
  List.nth st.board random

(*[is_unoccupied_continent my_countries continent] returns true if no countries
  in [continent] are occupied, and false otherwise *)
let rec is_unoccupied_continent my_countries continent =
  match my_countries with
  | [] -> true
  | (c, p, i)::t -> if (List.mem c continent.countries) then false
    else is_unoccupied_continent t continent

(*[get_unoccupied_continents occupied_countries continent_list acc] returns a
  list of all the unccupied continents in [continent_list]*)
let rec get_unoccupied_continents occupied_countries continent_list acc =
  match continent_list with
  | [] -> acc
  | h::t -> if (is_unoccupied_continent occupied_countries h)
    then get_unoccupied_continents occupied_countries t (h::acc)
    else get_unoccupied_continents occupied_countries t acc

(*[get_unoccupied_continent st continent_list] returns an occupied continent in
  [continent_list]*)
let rec get_random_unoccupied_continent st continent_list =
  let unoccupied_continents =
    get_unoccupied_continents st.occupied_countries st.board [] in
  Random.init (int_of_float (Unix.time()));
  let random = Random.int (List.length unoccupied_continents) in
  List.nth unoccupied_continents random

(*[get_random_country_in_continent continent] returns a random country in
  [continent]*)
let get_random_country_in_continent continent =
  Random.init (int_of_float (Unix.time ()));
  let random = Random.int (List.length (continent.countries)) in
  List.nth continent.countries random

(*[get_all_my_countries country_list acc] returns a list of all countries
  in [country_list] unbound from the player and number of troops occupying it *)
let rec get_all_my_countries country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i)::t -> get_all_my_countries t (c::acc)

(*[get_country_list_compliment a b] returns a list of all elements in list [b]
   that are not in list [a] *)
let rec get_country_list_compliment my_countries all_countries =
  List.filter (fun x -> not (List.mem x my_countries)) all_countries

(*[get_random_unoccupied_country st] returns a random country in st that is
  unoccupied *)
let get_random_unoccupied_country st =
  Random.init (int_of_float (Unix.time ()));
  let all_my_countries =
    get_all_my_countries st.occupied_countries [] in
  let all_enemy_countries =
    get_country_list_compliment all_my_countries (all_countries st) in
  let random = Random.int (List.length (all_enemy_countries)) in
  List.nth all_enemy_countries random

let ai_next_initial_reinforce st =
  let unoccupied_continents =
    get_unoccupied_continents st.occupied_countries st.board [] in
  if (List.length unoccupied_continents = 0)
  then ((get_random_unoccupied_country st).country_id)
  else (let random_continent = get_random_unoccupied_continent st st.board in
        let random_country = get_random_country_in_continent random_continent in
        random_country.country_id)

(*[is_enemy_country country current_player country_list] is true if [country] is
  an enemy country of [current_player], and false otherwise
  requires: [country] is an element in [country_list] *)
let rec is_enemy_country country current_player country_list =
  match country_list with
  | [] -> failwith "country is not in country list"
  | (c, p, i)::t -> if c.country_id = country.country_id
    then p.player_id <> current_player.player_id
    else is_enemy_country country current_player t

(*[is_interior_country enemy_countries current_player country] returns true if
  [country] has no enemy bordering countries, false otherwise*)
let rec is_interior_country enemy_countries current_player country =
  match enemy_countries with
  | [] -> true
  | (c, p, i)::t -> if (List.mem c.country_id country.bordering_countries)
    then false else is_interior_country t current_player country

(*[get_interior_countries my_countries enemy_countries current_player acc]
  returns a list of all countries in [my_countries] that do not border a country
  in [enemy_countries] *)
let rec get_interior_countries my_countries enemy_countries current_player acc =
  match my_countries with
  | [] -> acc
  | (c, p, i)::t -> if (is_interior_country enemy_countries current_player c)
    then get_interior_countries t enemy_countries current_player ((c,p,i)::acc)
    else get_interior_countries t enemy_countries current_player (acc)

(*[get_sum_border_troops my_countries current_player country acc] is the sum of
  the number of troops in all enemy countries that border [country]*)
let rec get_sum_border_troops my_countries current_player country acc =
  match my_countries with
  | [] -> acc
  | (c, p, i)::t ->
    if (List.mem c.country_id country.bordering_countries && p<>current_player)
    then (get_sum_border_troops t current_player country (i+acc))
    else (get_sum_border_troops t current_player country (acc))

(*[countries_and_enemies_difference st country_list acc] returns a tuple list
  of each country in in country_list bound to the difference between the number
  of troops in that country and the sum of the number of troops in that
  country's bordering countries *)
let rec countries_and_enemies_difference st country_list acc =
  match country_list with
  | [] -> acc
  | (c, p, i)::t ->
    (countries_and_enemies_difference st t
       ((c,(get_sum_border_troops st.occupied_countries st.player_turn c 0)-i)
        ::acc))

(*[country_to_reinforce country_differences acc] is the country in
  [country_differences] that is bound to the highest integer *)
let rec country_to_reinforce country_differences acc =
  match country_differences with
  | [] -> acc
  | (c, i)::t -> if i > (snd acc) then (c,i)
    else country_to_reinforce t acc

let rec ai_next_reinforce st =
  let my_countries =
    get_my_countries st.player_turn st.occupied_countries [] in
  let enemy_countries =
    get_country_list_compliment my_countries (st.occupied_countries) in
  let interior_countries =
    get_interior_countries my_countries enemy_countries st.player_turn [] in
  let frontier_countries =
    get_country_list_compliment interior_countries my_countries in
  let countries_and_enemies_difference_list =
    countries_and_enemies_difference st frontier_countries [] in
  let next_country =
    country_to_reinforce countries_and_enemies_difference_list
      (List.hd countries_and_enemies_difference_list) |> fst in
  next_country.country_id

(*[get_bordering_countries_with_ratio my_countries current_player country acc]
  returns a tuple of [country], each enemy bordering country of [country], and
  the ratio between the number of troops in [country] and that bordering
  country *)
let rec get_bordering_countries_with_ratio
    my_countries current_player country acc =
  match my_countries, country with
  | [], _ -> acc
  | (c, p, i)::t, (c0,p0,i0) ->
    if (List.mem c.country_id c0.bordering_countries
        && is_enemy_country c current_player my_countries)
    then get_bordering_countries_with_ratio t current_player country
        ((c0, c, (float_of_int i0) /. (float_of_int i))::acc)
    else get_bordering_countries_with_ratio t current_player country (acc)

(*[countries_and_enemies_ratio st country_list acc] returns a list of all
  countries in [country_list] bound to the ratio between the number of troops
  in a country and the number of troops in countries that border that country *)
let rec countries_and_enemies_ratio st country_list acc =
  match country_list with
  | [] -> acc
  | h::t ->
    countries_and_enemies_ratio st t
      ((get_bordering_countries_with_ratio
          st.occupied_countries st.player_turn h []) @ acc)

(*[country_to_attack country_ratios acc] is the next attack that the AI wants
  to execute, or ("none","none") if the AI does not want to attack *)
let rec country_to_attack country_ratios acc player =
  match country_ratios with
  | [] -> acc
  | (c_a, c_d, ratio)::t ->
    if (ratio > player.ratio) then (c_a.country_id, c_d.country_id)
    else country_to_attack t acc player

let rec ai_next_attack st=
  let my_countries =
    get_my_countries st.player_turn st.occupied_countries [] in
  let possible_attacks = countries_and_enemies_ratio st my_countries [] in
  country_to_attack possible_attacks ("none", "none") st.player_turn

let ai_next_reinforce_after_attack st country_id1 country_id2 =
  let country1 = get_country_assured (all_countries st) country_id1 in
  let country2 = get_country_assured (all_countries st) country_id2 in
  let country1_troops =
    get_num_troops country1.country_id st.occupied_countries in
  let country2_troops =
    get_num_troops country2.country_id st.occupied_countries in
  let country_1_border = get_sum_border_troops
      st.occupied_countries st.player_turn country1 0 in
  let country_2_border = get_sum_border_troops
      st.occupied_countries st.player_turn country2 0 in
  if country_1_border = 0 then country2.country_id
  else if country_2_border = 0 then country1.country_id
  else if (country_1_border - country1_troops
      > country_2_border - country2_troops)
  then country1.country_id
  else country2.country_id

(*[country_to_fortify_from interior_countries acc] is the country in
  [interior_countries] that is occupied by the most troops *)
let rec country_to_fortify_from interior_countries acc =
  match interior_countries with
  | [] -> acc
  | (c, i)::t -> if (i > snd acc) then country_to_fortify_from t (c, i)
    else country_to_fortify_from t acc

let rec ai_next_fortify st =
  let my_countries =
    get_my_countries st.player_turn st.occupied_countries [] in
  let enemy_countries =
    get_country_list_compliment my_countries (st.occupied_countries) in
  let interior_countries =
    get_interior_countries my_countries enemy_countries st.player_turn [] in
  let interior_countries' =
    List.map (fun (c, p, i) -> (c, i)) interior_countries in
  let next_country =
    country_to_fortify_from interior_countries'
      ({country_id = "none"; bordering_countries = []}, 1) in
  (fst next_country).country_id
