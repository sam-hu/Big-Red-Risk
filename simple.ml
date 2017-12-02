open Lymp

(* change "python3" to the name of your interpreter *)
let interpreter = "python3"
let py = init ~exec:interpreter "."
let simple = get_module py "simple"
let graphics = get_module py "graphics"

let cyclePlayers playerIDList headOfList=
  match playerIDList with
  | [] -> headOfList
  | h::t -> List.hd t

let () =
  (* msg = simple.get_message() *)

  let occupied_countries = Pylist [Pytuple [Pystr "Country one";Pystr "Player one";Pyint 556];
                                   Pytuple [Pystr "Country two";Pystr "Player one";Pyint 22];
                                   Pytuple [Pystr "Country three";Pystr "Player three";Pyint 486]] in
  let card_amounts = Pylist [Pytuple [Pystr "Player one";Pyint 5];
                             Pytuple [Pystr "Player two";Pyint 2];
                             Pytuple [Pystr "Player three";Pyint 1];] in

  let cash_card_reward = Pyint 15 in
  let dice_results = Pytuple [Pylist[Pyint 6; Pyint 5; Pyint 3];Pylist[Pyint 6; Pyint 1;]] in
  let turns_taken = 3 in

  let board = get graphics "drawBoard" [Pystr "Player one"] in
  let player_ids = ["Player one";"Player two";"Player three"] in
  let current_player_turn = "Player one" in

  let quit_loop = ref false in
  while not !quit_loop do
    print_string "Have you had enough yet? (y/n) ";

    let clicked = get graphics "clicker" [board] in
    let s = match clicked with
      | Pytuple [Pystr st; Pybool b] ->
        if (st = "End turn") then call graphics "updateBoard"
          [board;clicked;occupied_countries;card_amounts;cash_card_reward;
           Pyint turns_taken; dice_results;Pystr current_player_turn]
        else call graphics "updateBoard"
            [board;clicked;occupied_countries;card_amounts;cash_card_reward;
             Pyint turns_taken; dice_results;Pystr current_player_turn]
      | _ -> failwith "Should not be here"
    in s;

  (* let str = read_line () in
  if str.[0] = 'y' then
    quit_loop := true *)
    done;;



  (* let msg = get_string simple "get_message" [] in
	let integer = get_int simple "get_integer" [] in
	let addition = get_int simple "sum" [Pyint 12 ; Pyint 10] in
	let strconcat = get_string simple "sum" [Pystr "first " ; Pystr "second"] in
  Printf.printf "%s\n%d\n%d\n%s\n" msg integer addition strconcat ; *)



	close py
