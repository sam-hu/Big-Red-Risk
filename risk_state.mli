open Command
open Board

(* [state] is an abstract type containing information about the state of a game,
 * including the number of players, whose turn it is, total_turns played,
 * a list of active players, card reward, occupied country list, list of
 * player-owned continents, and the board map. *)
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
(* returns the number of troops present within the country specified by [target]
   Precondition: the country represented by [target] is in [country_list]*)
val get_num_troops : string -> (country*player*int) list -> int

(* returns the initial state of the game with number of players, list of
   players, and the game board passed in as parameters *)
val init_state : int -> Board.player list -> board -> state

(* returns trade command Same if 3 same cards can be traded in, Different if
   3 different cards can be traded in, or NoTrade if no cards can be traded in*)
val make_trade_command : state -> Command.trade_command

(* [trade_in cmd st] is the state that results after processing command [cmd]
 * [trade_in] allows the player to redeem cards for additional troops *)
val trade_in : Command.trade_command -> state -> state

(* returns Reinforce command if [to_country] is valid, FalseReinforce otherwise
 *)
val make_reinforce_command : string -> state -> Command.reinforce_command

(* [reinforce cmd st] is the state that results after processing command [cmd]
 * [reinforce] adds troops to a country of a player's choice, so long as the
 * player owns that country *)
val reinforce : Command.reinforce_command -> state -> state

(* returns Attack command if [attacker] and [defender] are valid countries
   FalseAttack otherwise *)
val make_attack_command : string -> string -> Command.loser -> int -> state -> Command.attack_command

(* [attack cmd st] is the state that results after processing command cmd
 * [attack] allows the player to select a country to attack an opponent's
 * country using a random dice-rolling system *)
val attack : Command.attack_command -> state -> state

(* returns Fortify command if [from_country] is a valid country to fortify from,
   FalseFortify otherwise *)
val make_fortify_command : string -> state -> Command.fortify_command

(* [fortify cmd st] is the state that results after processing command cmd
 * [fortify] allows the player to move troops from one country to another
 * country reachable from the first country through adjacent bordering countries *)
val fortify : Command.fortify_command -> state -> state

(* returns [st] with current player updated to reflect the next player's turn
   Precondition: [st] has between 1 and 4 active players *)
val next_player: state -> state

(* returns Reinforce command if [to_country] is a valid country,
   FalseReinforce otherwise *)
val init_reinforce_command: string -> state -> Command.reinforce_command

(* returns [st] if [cmd] is FalseReinforce, or a new state where the player
   adds a troop to an unoccupied country at the beginning of the game *)
val reinforce_begin: Command.reinforce_command -> state -> state

(* returns a new state similar to [st] except the current player is given a
   minimum of three undeployed troops, based on countries and continents owned *)
val give_troops: state -> state

(* returns the number of troops in [target] country
   Precondition: [target] represents a country in [country_list] *)
val get_num_troops: string -> (Board.country * Board.player * int) list -> int

(* returns new state similar to [st], except that the continents field is
   updated to show the continents the current player owns *)
val build_continent_list: state -> state

(* returns new state with the player given a random card if player owns more
   countries in [st2] than [st1], returns [st2] otherwise *)
val give_card: state -> state -> state

(* returns true if all [players] have 0 undeployed troops, false otherwise *)
val all_troops_deployed : player list -> bool

(* Returns: true if [player] owns the country identified by [country_string]
   in [occupied_list], false otherwise *)
val owns_country: string -> (Board.country*Board.player*int) list -> Board.player -> bool

(* Returns true if there is a winner in [st], false otherwise *)
val check_if_win: state -> bool

(* returns new state with players that have 0 occupied countries removed from
   the game *)
val remove_player: state -> state

(* returns the number of countries [player] occupies in [occupied] *)
val num_countries: Board.player -> (Board.country * Board.player * int) list -> int -> int

(* returns a list of all countries in [continent_list] *)
val get_all_countries: Board.continent list -> Board.country list -> Board.country list

(* returns the country in [country_list] with country_id [target]
 * Precondition: [target] is in country_list *)
val get_country_assured: Board.country list -> string -> Board.country

(* returns true if the command is Reinforce, false if it is FalseReinforce *)
val is_reinforce: Command.reinforce_command -> bool
