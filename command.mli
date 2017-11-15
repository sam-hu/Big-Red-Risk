(*[point] is a point on the users screen *)
type point

(* [command] represents a command input by a player. *)
type command



(* [parse point1 point2 str1] is the command that represents player input
   [point1] [point2] [str1]
 * requires: [point1] and [point2] are points on the gui, str1 is a string
   describing the type of command*)
val parse : point -> point -> string -> command


(* [makeAttackCommand point1 point2] creates a attack command
 * requires: [point1] and [point2] are points. *)
val makeAttackCommand: point -> point -> command

(* [makeReinforceCommand point1] creates a reinforce command
 * requires: [point1] is a point. *)
val makeReinforceCommand: point -> command

(* [makeFortifyCommand point1 point2] creates a reinforce command
 * requires: [point1] and [point2] are points. *)
val makeFortifyCommand: point -> point -> command

(* [makeTradeInCommand] creates a trade-in command  *)
val makeTradeInCommand:  command

(* [makePassCommand str] creates a pass command  *)
val makePassCommand: command

(* [makeCommand point1 point2 str1] creates one of the 5 valid commands or a false command
 * requires: [point1] and [point2] are point, and [str1] is a string *)
val makeCommand: point -> point -> string -> command

(* [falseCommand] creates a false command  *)
val falseCommand: command
