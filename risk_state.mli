open Command
open Board
(* [state] is an abstract type containing information about the state of a game,
 * including the number of players, whose turn it is, the number of units/cards
 * belonging to each player, the total number of turns etc. *)
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

val get_num_troops : string -> (country*player*int) list -> int

(* [init_state bd p_list st] is the initial state of the game board [bd] with
 * the players in [p_list] *)
val init_state : int -> Board.player list -> board -> state

val make_trade_command : state -> Command.trade_command

(* [trade_in cmd st] is the state that results after processing command cmd
 * [trade_in] allows the player to redeem cards for additional troops *)
val trade_in : Command.trade_command -> state -> state

val make_reinforce_command : string -> state -> Command.reinforce_command

(* [reinforce cmd st] is the state that results after processing command cmd
 * [reinforce] adds troops to a country of a player's choice, so long as the
 * owns that country *)
val reinforce : Command.reinforce_command -> state -> state

val make_attack_command : string -> string -> Command.loser -> int -> state -> Command.attack_command

(* [attack cmd st] is the state that results after processing command cmd
 * [attack] allows the player to select a country to attack an opponent's
 * country using a randogm dice-rolling system *)
val attack : Command.attack_command -> state -> state

val make_fortify_command : string -> state -> Command.fortify_command

(* [fortify cmd st] is the state that results after processing command cmd
 * [fortify] allows the player to move troops from one country to another
 * country reachable from the first country through adjacent bordering countries *)
val fortify : Command.fortify_command -> state -> state

(* [pass cmd st] is the state that results after processing command cmd
 * [pass] allows the user to do nothing during his or her turn, or to signal the
 * end of a turn *)
val pass : Command.pass_command -> state -> state

val next_player: state -> state

val reinforce_begin: Command.reinforce_command -> state -> state

val give_troops: state -> state

val get_num_troops: string -> (Board.country * Board.player * int) list -> int

val build_continent_list: state -> state

val give_card: state -> state -> state

val init_reinforce_command: string -> state -> Command.reinforce_command

val all_troops_deployed : player list -> bool

val owns_country: string -> (Board.country*Board.player*int) list -> Board.player -> bool

val print_player: Board.player -> unit

val check_if_win: state -> bool

val remove_player: state -> state

val num_countries: Board.player -> (Board.country * Board.player * int) list -> int -> int
