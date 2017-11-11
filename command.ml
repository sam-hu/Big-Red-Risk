(* A type exposed and defined in a .mli file must also be defined in
 * the corresponding .ml file.  So you must repeat the definition
 * of [command] here.  This helps OCaml achieve something called
 * "separate compilation", which you could google for.  Yes,
 * it's a little bit annoying, but there is a good reason for it. *)
type command = {
  com: string;
  word: string;
}

(* [makeGoCommand direction] creates a go command with c.word of [direction].
 * requires: [direction] is a string. *)
let makeGoCommand direction = {
  com = "go";
  word = direction;
}

(* [makeCommand c w] creates a command with c.com of [c] and
 * c.word of [w].
 * requires: [c] and [w] are strings. *)
let makeCommand c w = {
  com = c;
  word = w;
}

(* [falseCommand] creates a false command with c.com of "" and c.word of "".
 * requires: None. *)
let falseCommand = {
  com = "";
  word = "";
}

(* [parse str] is the command that represents player input [str].
 * requires: [str] is one of the commands forms described in the
 *   assignment writeup. *)
let parse str =
  let lowercaseStr = String.lowercase_ascii str in
  let wordsList = String.split_on_char ' ' lowercaseStr in
  let firstWord = List.hd wordsList in
  if List.length wordsList = 1 && (firstWord = "quit" || firstWord = "look" ||
                                   firstWord = "inventory" || firstWord = "inv" ||
                                   firstWord = "score" || firstWord = "turns")
    then makeCommand (firstWord) ""
  else if List.length wordsList = 1 then makeGoCommand (List.hd wordsList)
  else if List.length wordsList > 1 &&
          (firstWord = "go" || firstWord = "take" || firstWord = "drop") then
    makeCommand (firstWord) (String.concat " " (List.tl wordsList))
  else if List.length wordsList > 1 then makeGoCommand
      (String.concat " " (wordsList))
  else falseCommand
