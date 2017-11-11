(* [command] represents a command input by a player. *)
(* You may redefine [command] to be synonymous with whatever
 * type you wish, but its name must not be changed.
 * It is okay to expose this type rather than make it abstract,
 * because it is not the representation type of a data structure. *)
type command = {
  com: string;
  word: string;
}

(********************************************************
 * DO NOT CHANGE THIS CODE
 * It is part of the interface the course staff will
 * use to test your submission.
 *)

(* [parse str] is the command that represents player input [str].
 * requires: [str] is one of the commands forms described in the
 *   assignment writeup. *)
val parse : string -> command

(* END DO NOT CHANGE
 ********************************************************)
(* You are free to add more code below *)

(* [makeGoCommand str] creates a go command with c.word of [str].
 * requires: [str] is a string. *)
val makeGoCommand: string -> command

(* [makeCommand str1 str2] creates a command with c.com of [str1] and
 * c.word of [str2].
 * requires: [str1] and [str2] are strings. *)
val makeCommand: string -> string -> command

(* [falseCommand] creates a false command with c.com of "" and c.word of "".
 * requires: None. *)
val falseCommand: command
