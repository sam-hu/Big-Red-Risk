(*[point] is a point on the users screen *)
(* type point *)

(* [command] represents a command input by a player. *)
type attack_command = (string*string)

type reinforce_command = string

type fortify_command = string

type trade_command

type pass_command = unit

(* [parse point1 point2 str1] is the command that represents player input
   [point1] [point2] [str1]
 * requires: [point1] and [point2] are points on the gui, str1 is a string
   describing the type of command*)
(* val parse : point -> point -> string -> command *)


(* [makeAttackCommand point1 point2] creates a attack command
 * requires: [point1] and [point2] are points. *)
(* val make_attack_command: point -> point -> attack_command *)

(* [makeReinforceCommand point1] creates a reinforce command
 * requires: [point1] is a point. *)
(* val make_reinforce_command: point -> reinforce_command *)

(* [makeFortifyCommand point1 point2] creates a reinforce command
 * requires: [point1] and [point2] are points. *)
(* val make_fortify_command: point -> point -> fortify_command *)

(* [makeTradeInCommand] creates a trade-in command  *)
(* val make_trade_command:  trade_command *)

(* [makePassCommand str] creates a pass command  *)
(* val make_pass_command: pass_command *)

(* [makeCommand point1 point2 str1] creates one of the 5 valid commands or a false command
 * requires: [point1] and [point2] are point, and [str1] is a string *)
(* val make_command: point -> point -> string -> command *)

(* [falseCommand] creates a false command  *)
(* val false_command: command *)
