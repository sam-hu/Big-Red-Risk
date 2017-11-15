(* [state] is an abstract type containing information about the state of a game,
 * including the number of players, whose turn it is, the number of units/cards
 * belonging to each player, the total number of turns etc. *)
type state

(* [trade_in cmd st] is the state that results after processing command cmd *)
val trade_in : Command.command -> state -> state

(* [reinforce cmd st] is the state that results after processing command cmd *)
val reinforce : Command.command -> state -> state

(* [attack cmd st] is the state that results after processing command cmd *)
val attack : Command.command -> state -> state

(* [fortify cmd st] is the state that results after processing command cmd *)
val fortify : Command.command -> state -> state

(* [pass cmd st] is the state that results after processing command cmd *)
val pass : Command.commmand -> state -> state
