(* A [country] is a record representing each individual country on the board.
   It contains a country's ID, bordering countries, number of troops,
   ID of player occupying, and its continent. *)
type country = {
  country_id: string;
  bordering_countries: string list;
}

(* A [continent] is a list of countries that are part of this continent, and the
   continent's ID. *)
type continent = {
  countries: country list;
  id: string;
  bonus: int
}

(* A [card] is either of type Circle, Square, or Triangle. *)
type card = Circle | Triangle | Square

(* A [player] represents a player playing the game. It contains a player's ID,
   countries occupied, continents occupied, number of troops, and score. It will
   also contain information of whether the specific player is an AI or a human.
*)
type player = {
  player_id: string;
  num_deployed: int;
  num_undeployed: int;
  cards: card list;
  ai: bool;
  ratio: float
}

(* A [board] is a graph of countries where countries that border each other are
 * connected on the graph. *)
type board = continent list

(*[graphboard] is the main board we use for our game, modeled after the Cornell
  campus*)
val graphboard : board

(*The following are profiles for players that will be controlled by humans
  initialized to default values*)
val p1: player

val p2: player

val p3: player

val p4: player
