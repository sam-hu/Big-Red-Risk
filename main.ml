(*
 * CS 3110 Fall 2017 A2
 * Author: Ohad Koronyo
 * NetID: ork6
 *
 * Acknowledge here any contributions made to your solution that
 * did not originate from you or from the course staff:
 *
 *)

(* [play_game f] plays the game in adventure file [f]. *)
open Yojson.Basic.Util
open State
open Command

let rec string_list_display (inv: string list) =
  match inv with
  | [] -> ()
  | h::t -> Pervasives.print_endline h; string_list_display t


(* [turn_maker s firstWin] is the heart of the game engine's REPL; it reads the
 * user's command, does that command on [s], prints relevant information, and
 * passes the new state as a recursive call to itself. The function also checks
 * if [firstWin] is true, and if it is true as well as win_score [s] has been
 * achieved, then the win message of the adventure is displayed (and [firstWin]
 * is set to false)
 * requires: [s] is a valid state and [firstWin] is a boolean
*)
let rec turn_maker (s: state) (firstWin: bool) =
  Pervasives.print_endline "";
  if (score s = win_score s && firstWin) then (ANSITerminal.(print_string [blue]
                                (win_message_string s)); turn_maker s false;
                                 Pervasives.print_endline "";) else ();
  let typer = Pervasives.print_string "> " in
  let c = parse (read_line ()) in
  let ns = do' c s in
  if c.com = "quit" then (typer; Pervasives.print_endline "Exiting Game...";
                          Pervasives.print_endline ""; exit 0)
  else if c.com = "go" then if current_room_id ns = current_room_id s then
      (Pervasives.print_endline "";
       Pervasives.print_endline "Cannot move to that location!";
       turn_maker ns firstWin;) else
      ((ANSITerminal.(print_string [red] (room_description ns));
    Pervasives.print_endline ""; Pervasives.print_endline "";
    ANSITerminal.(print_string [green] "Items in this location:");
     Pervasives.print_endline "");
     string_list_display (items_in_room ns); typer; turn_maker ns firstWin;)
  else if c.com = "look" then
    (ANSITerminal.(print_string [red] (room_description ns));
     Pervasives.print_endline ""; Pervasives.print_endline "";
     ANSITerminal.(print_string [green] "Items in this location:");
     Pervasives.print_endline "";
     string_list_display (items_in_room ns); typer; turn_maker ns firstWin;)
  else if c.com = "inventory" || c.com = "inv" then
    (if List.length (inv ns) = 0 then
       (ANSITerminal.(print_string [green] "Inventory Empty");
        Pervasives.print_endline "";)
     else string_list_display (inv ns);
     typer; turn_maker ns firstWin;)
  else if c.com = "take" then if inv ns = inv s then
      (Pervasives.print_endline "";
       Pervasives.print_endline "Item cannot be taken!";
       turn_maker ns firstWin;) else turn_maker ns firstWin
  else if c.com = "drop" then if inv ns = inv s then
      (Pervasives.print_endline "";
       Pervasives.print_endline "Item cannot be dropped!";
       turn_maker ns firstWin;) else turn_maker ns firstWin
  else if c.com = "score" then
    (Pervasives.print_int (score ns); Pervasives.print_endline "";
     typer; turn_maker ns firstWin;)
  else if c.com = "turns" then
    (Pervasives.print_int (turns ns); Pervasives.print_endline "";
     typer; turn_maker ns firstWin;)

  else turn_maker ns firstWin


(* [play_game f] begins the REPL by parsing the .json file, printing some
 * introductory information, and calling [turn_maker s firstWin] with
 * [init_state (Yojson.Basic.from_file f)] and ["true"]
 * requires: f is the name of a .json file
*)
let play_game f =
  try
    let s = init_state (Yojson.Basic.from_file f) in
    Pervasives.print_endline "";

    ANSITerminal.(print_string [blue]
"Instructions: type go [direction] or go [room], or simply [direction] or [room], \n
to move to a different location. Type take [item] to add an item to your inventory, \n
and drop and item with drop [item]. Type look to bring up the description of the current location, \n
type inventory or inv to bring up the items you're holding, type score to find out your current points,\n
type turns to find out the number of turns you took, and type quit to exit the adventure.
");
    Pervasives.print_endline "";
    ANSITerminal.(print_string [red] (room_description s));
    Pervasives.print_endline ""; Pervasives.print_endline "";
    ANSITerminal.(print_string [green] "Items in this location:");
    Pervasives.print_endline "";
    string_list_display (items_in_room s);
    turn_maker s true
  with _ -> Pervasives.print_endline "";
    Pervasives.print_endline "Invalid File Name or Game File! Quitting...";
    Pervasives.print_endline ""

(* [main ()] starts the REPL, which prompts for a game to play.
 * You are welcome to improve the user interface, but it must
 * still prompt for a game to play rather than hardcode a game file. *)
let main () =
  ANSITerminal.(print_string [red]
    "\n\nWelcome to the 3110 Text Adventure Game engine.\n");
  print_endline "Please enter the name of the game file you want to load.\n";
  print_string  "> ";
  match read_line () with
  | exception End_of_file -> ()
  | file_name -> play_game file_name

let () = main ()
