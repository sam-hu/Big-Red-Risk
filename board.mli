(* A [board] is a graph of countries where countries that border each other are
 * connected on the graph. *)
type board

(* A [country] is a record representing each individual country on the board.
   It contains a country's ID, bordering countries, number of troops,
   ID of player occupying, and its continent. *)
type country

(* A [continent] is a list of countries that are part of this continent, and the
   continent's ID. *)
type continent

(* A [card] is either of type Circle, Square, or Triangle. *)
type card

(* A [player] represents a player playing the game. It contains a player's ID,
   countries occupied, continents occupied, number of troops, and score. It will
   also contain information of whether the specific player is an AI or a human.
*)
type player
