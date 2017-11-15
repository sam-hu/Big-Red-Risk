(* A [country] is a record representing each individual country on the board.
   It contains a country's ID, bordering countries, number of troops,
   ID of player occupying, and its continent. *)
type country

(* A [continent] is a list of countries that are part of this continent *)
type continent

(* A [card] is either of type Circle, Square, or Triangle. *)
type card

(* A [player] represents a player playing the game. It contains a player's ID,
   countries occupied, continents occupied, number of troops, and score. *)
type player
