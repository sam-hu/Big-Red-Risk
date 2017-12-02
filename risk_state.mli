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
  occupied_continents: (continent*player) list;
  board: board;
}

(* [init_state bd p_list st] is the initial state of the game board [bd] with
 * the players in [p_list] *)
val init_state : int -> Board.player list -> state

(* [trade_in cmd st] is the state that results after processing command cmd
 * [trade_in] allows the player to redeem cards for additional troops *)
val trade_in : Command.trade_command -> state -> state

(* [reinforce cmd st] is the state that results after processing command cmd
 * [reinforce] adds troops to a country of a player's choice, so long as the
 * owns that country *)
val reinforce : Command.reinforce_command -> state -> state

(* [attack cmd st] is the state that results after processing command cmd
 * [attack] allows the player to select a country to attack an opponent's
 * country using a randogm dice-rolling system *)
val attack : Command.attack_command -> state -> state

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
