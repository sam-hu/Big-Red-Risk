(********************************************************
 * DO NOT CHANGE THIS CODE
 * It is part of the interface the course staff will
 * use to test your submission.
 *)

(* [state] is an abstract type representing the state of an adventure. *)
type state

(* [init_state j] is the initial state of the game as
 * determined by JSON object [j].
 * requires: [j] represents an error-free adventure file. *)
val init_state : Yojson.Basic.json -> state

(* [win_score s] is the winning score for the adventure whose current
 * state is represented by [s]. *)
val win_score : state -> int

(* [score s] is the player's current score. *)
val score : state -> int

(* [turns s] is the number of turns the player has taken so far. *)
val turns : state -> int

(* [current_room_id s] is the id of the room in which the adventurer
 * currently is. *)
val current_room_id : state -> string

(* [inv s] is the list of item id's in the adventurer's current inventory.
 * No item may appear more than once in the list.  Order is irrelevant. *)
val inv : state -> string list

(* [visited s] is the list of id's of rooms the adventurer has visited.
 * No room may appear more than once in the list.  Order is irrelevant. *)
val visited : state -> string list

(* [locations s] is an association list mapping item id's to the
 * id of the room in which they are currently located.  Items
 * in the adventurer's inventory are not located in any room.
 * No item may appear more than once in the list.  The relative order
 * of list elements is irrelevant, but the order of pair components
 * is essential:  it must be [(item id, room id)]. *)
val locations : state -> (string*string) list

(* [do' c st] is [st'] if doing command [c] in state [st] results
 * in a new state [st'].  The function name [do'] is used because
 * [do] is a reserved keyword.  Define the "observable state" to
 * be all the information that is observable about the state
 * from the functions above that take a [state] as input.
 *   - The "go" (and its shortcuts), "take" and "drop" commands
 *     result in an appropriately updated [st'], as described in the
 *     assignment writeup, if their object is valid in
 *     state [st].  If their object is invalid in state [st],
 *     the observable state remains unchanged in [st'].
 *       + The object of "go" is valid if it is a direction by which
 *         the current room may be exited, and if the union of the items
 *         in the player's inventory and the current room contains
 *         all the keys required to move to the target room.
 *       + The object of "take" is valid if it is an item in the
 *         current room.
 *       + The object of "drop" is valid if it is an item in the
 *         current inventory.
 *       + If no object is provided (i.e., the command is simply
 *         the bare word "go", "take", or "drop") the behavior
 *         is unspecified.
 *   - The "quit", "look", "inventory", "inv", "score", and "turns"
 *     commands are always possible and leave the observable state unchanged.
 *   - The behavior of [do'] is unspecified if the command is
 *     not one of the commands given in the assignment writeup.
 * effects: none.  [do'] is not permitted to do any printing as
 *   part of implementing the REPL.  [do'] is not permitted to cause
 *   the engine to terminate.  [do'] is not permitted to raise an exception
 *   unless the precondition is violated.
 * requires: the input state was produced by [init_state] from an
 *   error-free adventure file, or by repeated applications of [do']
 *   to such a state.
 *)
val do' : Command.command -> state -> state

(* END DO NOT CHANGE
 ********************************************************)
(* You are free to add more code below *)

(* [room_description s] is the string description of the current_room of [s]
 * requires: [s] is a valid state *)
val room_description: state -> string

(* [items_in_room s] gives a string list of the items in your inventory at [s]
 * requires: [s] is a valid state *)
val items_in_room: state -> string list

(* [win_message_string s] gives the winning_message of state [s] as a string
 * requires: [s] is a valid state *)
val win_message_string: state -> string
