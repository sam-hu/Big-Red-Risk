(* [state] represents the state of an adventure. *)
(* You may define [state] to be whatever type you wish here. *)
open Yojson.Basic.Util
open Command

(* Defines type description as the description of a room, with two fields:
 * requires: string list of required items to display this description
 * text: string of the text of the description *)
type description = {
  requires: string list;
  text: string;
}

(* Defines type exit as the exit of a room, with three fields:
 * direction: string of direction of the exit from the current room
 * room_id: string of room's id
 * keys: string list of necessary items to take this exit
*)
type exit = {
  direction: string;
  room_id: string;
  keys: string list;
}

(* Defines type room with five fields:
 * id: string of room's id
 * descriptions: description list of possible descriptions for this room
 * points: int of points given to player by entering this room
 * exits: exit list of all exits from this room
 * treasure: string list of items whose points are activated once dropped in this
   room
*)
type room = {
  id: string;
  descriptions: description list;
  points: int;
  exits: exit list;
  treasure: string list;
}

(* Defines type item as an item in the game, with three fields:
 * id: string of item's id
 * description: string of description of item
 * points: int of points of the item when dropped in its treasure room
*)
type item = {
  id: string;
  description: string;
  points: int;
}

(* Defines type location as an item's location, with two fields:
 * room: string of room's id
 * item: string of item's id
*)
type location = {
  room: string;
  item: string;
}

(* Defines type game as the current game, with six fields:
 * rooms: room list of all rooms in the game
 * items: item list of all items in the game
 * start_room: string of starting room's id
 * start_inv: string list of items in starting inventory
 * start_locations: location list of starting locations of all items
 * win_message: string of winning message for the adventure
*)
type game = {
    rooms : room list;
    items : item list;
    start_room : string;
    start_inv: string list;
    start_locations: location list;
    win_message: string;
  }

(* Defines type state as the current game state, with seven fields:
 * current_room: room of the current room in this state
 * inventory: item list of items in current state's inventory
 * points: int of points in current state
 * turns: int of turns taken by current state
 * rooms_visited: string list of rooms visited by current state
 * item_locations: location list of item locations in current state
 * game: game of game record associated with this state
*)
type state = {
  current_room: room;
  inventory: item list;
  points: int;
  turns: int;
  rooms_visited: string list;
  item_locations: location list;
  game: game;
}

(* [an_item j] constructs an item from information in game file [j]
 * requires: [j] is a parsed .json game file
*)
let an_item j = {
  id = j |> member "id" |> to_string;
  description = j |> member "description" |> to_string;
  points = j |> member "points" |> to_int;
}

(* [a_location j] constructs a location from information in game file [j]
 * requires: [j] is a parsed .json game file
*)
let a_location j = {
  room = j |> member "room" |> to_string;
  item = j |> member "item" |> to_string;
}

(* [a_description j] constructs a description from information in game file [j]
 * requires: [j] is a parsed .json game file
*)
let a_description j = {
  requires = j |> member "requires" |> to_list |> List.map to_string;
  text = j |> member "text" |> to_string;
}

(* [an_exit j] constructs an exit from information in game file [j]
 * requires: [j] is a parsed .json game file
*)
let an_exit j = {
  direction = j |> member "direction" |> to_string;
  room_id = j |> member "room_id" |> to_string;
  keys = j |> member "keys" |> to_list |> List.map to_string;
}

(* [a_room j] constructs a room from information in game file [j]
 * requires: [j] is a parsed .json game file
*)
let a_room j = {
  id = j |> member "id" |> to_string;
  descriptions = j |> member "descriptions" |> to_list |> List.map a_description;
  points = j |> member "points" |> to_int;
  exits = j |> member "exits" |> to_list |> List.map an_exit;
  treasure = j |> member "treasure" |> to_list |> List.map to_string;
}

(* [game' j] constructs a game from information in game file [j]
 * requires: [j] represents an error-free adventure file. *)
let game' j = {
  rooms = j |> member "rooms" |> to_list |> List.map a_room;
  items = j |> member "items" |> to_list |> List.map an_item;
  start_room = j |> member "start_room" |> to_string;
  start_inv = j |> member "start_inv" |> to_list |> List.map to_string;
  start_locations = j |> member "start_locations" |> to_list |> List.map a_location;
  win_message = j |> member "win_message" |> to_string;
}

(* [find_room roomList fID] finds the room in [roomList] with room_id of [fID]
 * requires: [roomList] is a room list
 *           [fID] is a string of a room's id
*)
let rec find_room (roomList: room list) (fID:string) =
  match roomList with
  | [] -> failwith "Error: Room Not Found"
  | h::t -> if h.id = fID then h else (find_room t fID)

(* [find_item] finds the item in [itemList] with item id of [iID]
 * requires: [itemList] is an item list
 *           [iID] is a string of an item's id
*)
let rec find_item (itemList: item list) (iID:string) =
  match itemList with
  | [] -> failwith "Error: Item Not Found"
  | h::t -> if h.id = iID then h else (find_item t iID)

(* [delete_item_from_locs locList iString] deletes an the item with id [iStrin]
 * from  location list [locList]
 * requires: [locList] is a location list
 *           [iString] is a string of an item's id
*)
let rec delete_item_from_locs (locList: location list) (iString: string) =
  match locList with
  | [] -> locList
  | h::t -> if h.item = iString then delete_item_from_locs t iString
    else h :: (delete_item_from_locs t iString)

(* [make_inventory itemList inputList finaList] creates an inventory with items
 * from [itemList] and only those with id's in [inputList] are appended to
 * [finalList]
 * requires: [itemList] is an item list
 *           [inputList] is a string list of item id's
 *           [finalList] is an item list
*)
let rec make_inventory (itemList: item list) (inputList: string list) finalList =
  match itemList with
  |[] -> finalList
  | h::t -> if List.mem h.id inputList then make_inventory t inputList (h::finalList)
    else make_inventory t inputList finalList

(* [location_to_string locationList stringByStringList] converts a location list
 * [locationList] to a (string*string) list [stringByStringList]
 * requires: [locationList] is location list
 *           [stringByStringList] is a (string*string) list
*)
let rec location_to_string (locationList: location list) stringByStringList =
  match locationList with
  | [] -> stringByStringList
  | h::t -> location_to_string t ((h.room, h.item) :: stringByStringList)

(* [inv_to_string inventoryList stringList] converts an item list [inventoryList]
 * to a string list [stringList]
 * requires: [inventoryList] is an item list
 *           [stringList] is a string list
*)
let rec inv_to_string (inventoryList: item list) stringList =
  match inventoryList with
  | [] -> stringList
  | h::t -> inv_to_string t (h.id :: stringList)

(* [item_in_treasure_room roomList i] returns true if an item with location [i]
 * is in its treasure room from a list of rooms [roomList]
 * requires: [roomList] is a room list
 *           [i] is an (item's) location
*)
let rec item_in_treasure_room (roomList: room list) (i: location) =
  match roomList with
  | [] -> false
  | h::t -> if (List.mem i.item h.treasure && i.room = h.id) then true
    else item_in_treasure_room t i

(* [an_items_points allItemsList iString] returns the points of an item with id
 * [iString] from the item list [allItemList]
 * requires: [allItemList] is an item list
 *           [iString] is a string of an item's id
*)
let rec an_items_points (allItemsList: item list) (iString: string) =
  match allItemsList with
  | [] -> failwith "Error: Item Points Not Found"
  | h::t -> if iString = h.id then h.points else an_items_points t iString

(* [start_points j roomList itemList totalPoints] returns the game's start points
 * from information in [roomList] and [itemList], and is stored in [totalPoints]
 * throughout the recursion
 * requires: [roomList] is a room list
 *           [itemList] is a location list
 *           [totalPoints] is an int
*)
let rec start_points j (roomList: room list) (itemList: location list) (totalPoints:int) =
  match itemList with
  | [] -> totalPoints
  | h::t -> if item_in_treasure_room roomList h then
      start_points j roomList t ((an_items_points (j |> member "items" |> to_list |> List.map an_item) h.item)
                               + totalPoints) else
      start_points j roomList t (totalPoints)

(* [init_state j] is the initial state of the game as
 * determined by JSON object [j].
 * requires: [j] represents an error-free adventure file. *)
let init_state j = {
  current_room = find_room (j |> member "rooms" |> to_list |> List.map a_room)
      (j |> member "start_room" |> to_string);
  inventory = make_inventory (j |> member "items" |> to_list |> List.map an_item)
      (j |> member "start_inv" |> to_list |> List.map to_string) [];
  points =  start_points j (game' j).rooms
      (j |> member "start_locations" |> to_list |> List.map a_location)
      (find_room (j |> member "rooms" |> to_list |> List.map a_room)
                         (j |> member "start_room" |> to_string)).points;
  turns = 0;
  rooms_visited = (j |> member "start_room" |> to_string)::[];
  item_locations = j |> member "start_locations" |> to_list |> List.map a_location;
  game = game' j;
}

(* [sum_of_all_rooms roomList sum] returns the points associated with all rooms
 * in [roomList], and [sum] keeps that value throughout the recursion
 * requires: [roomList] is a room list
 *           [sum] is an int representing number of points
*)
let rec sum_of_all_rooms (roomList: room list) (sum: int) =
  match roomList with
  | [] -> sum
  | h::t -> sum_of_all_rooms t (h.points + sum)

(* [sum_of_all_items itemList sum] returns the points associated with all items
 * in [itemList], and [sum] keeps that value throughout the recursion
 * requires: [itemList] is an item list
 *           [sum] is an int representing number of points
*)
let rec sum_of_all_items (itemList: item list) (sum: int) =
  match itemList with
  | [] -> sum
  | h::t -> sum_of_all_items t (h.points + sum)

(* [win_score s] is the winning score for the adventure whose current
 * state is represented by [s].
 * requires: [s] is a state
 *)
let win_score s =
  let sumOfRooms = sum_of_all_rooms s.game.rooms 0 in
  let sumOfItems = sum_of_all_items s.game.items 0 in
  sumOfRooms + sumOfItems

(* [score s] is the player's current score.
 * requires: [s] is a state
*)
let score s = s.points

(* [turns s] is the number of turns the player has taken so far.
 * requires: [s] is a state
*)
let turns s = s.turns

(* [current_room_id s] is the id of the room in which the adventurer
 * currently is.
 * requires: [s] is a state
*)
let current_room_id s = s.current_room.id

(* [inv s] is the list of item id's in the adventurer's current inventory.
 * No item may appear more than once in the list.  Order is irrelevant.
 * requires: [s] is a state
*)
let inv s = inv_to_string s.inventory []

(* [visited s] is the list of id's of rooms the adventurer has visited.
 * No room may appear more than once in the list.  Order is irrelevant.
 * requires: [s] is a state
*)
let visited s = s.rooms_visited

(* [locations s] is an association list mapping item id's to the
 * id of the room in which they are currently located.  Items
 * in the adventurer's inventory are not located in any room.
 * No item may appear more than once in the list.  The relative order
 * of list elements is irrelevant, but the order of pair components
 * is essential:  it must be [(item id, room id)].
 * requires: [s] is a states
*)
let locations s = location_to_string s.item_locations []

(* [make_state croom inv pts trns rvisited ilocs g] creates a state from values
 * [croom], [inv], [pts], [trns], [rvisited], [ilocs], and [g]
 * requires: [croom] is a room representing the current room
 *           [inv] is an item list representing the inventory
 *           [pts] is an int representing the number of points
 *           [trns] is an int representing the number of turns
 *           [rvisited] is a string list of the rooms visited
 *           [ilocs] is a location list of the items
 *           [g] is the game associated with the state
*)
let make_state (croom: room) (inv: item list) (pts: int) (trns: int)
    (rvisited: string list) (ilocs: location list) (g: game) = {
  current_room = croom;
  inventory = inv;
  points = pts;
  turns = trns;
  rooms_visited = rvisited;
  item_locations = ilocs;
  game = g;
}

(* [valid_direction exitList d] returns true if direction string [d] is in
 * [exitList]
 * requires: [exitList] is an exit list
 *           [d] is a string of a direction
*)
let rec valid_direction (exitList: exit list) (d: string) =
  match exitList with
  | [] -> false
  | h::t -> if h.direction = d then true else valid_direction t d

(* [valid_room_from_current exitList rString] returns true if the room with id
 * [rString] is a room in [exitList]
 * requires: [exitList] is an exit list
 *           [rString] is a string of a room's id
*)
let rec valid_room_from_current (exitList: exit list) (rString: string) =
  match exitList with
  | [] -> false
  | h::t -> if h.room_id = rString then true else valid_room_from_current t rString

(* [get_room_from_exit exitList d] returns the room with direction [d] from an
 * exit in [exitList]
 * requires: [exitList] is an exit list
 *           [d] is a string of a direction
*)
let rec get_room_from_exit (exitList: exit list) (d: string) =
  match exitList with
  | [] -> failwith "Error: Room not found in exit"
  | h::t -> if h.direction = d then h.room_id else get_room_from_exit t d

(* [get_exit_from_room exitList rString] returns the exit in [exitList] with a
 * room that has id [rString]
 * requires: [exitList] is an exit list
 *           [rString] is a string of a room's id
*)
let rec get_exit_from_room (exitList: exit list) (rString: string) =
  match exitList with
  | [] -> failwith "Error: Exit not found from room"
  | h::t -> if h.room_id = rString then h else get_exit_from_room t rString

(* [key_not_in_inv key inv] returns true if the [key] is not in [inv]
 * requires: [key] is a string of an item's id
 *           [inv] is an item list
*)
let rec key_not_in_inv (key:string) (inv: item list) =
  match inv with
  | [] -> true
  | h::t -> if h.id = key then false else key_not_in_inv key t

(* [key_not_in_locations key locs currentRoom] returns true if the [key] is not
 * in [locs], with information from [currentRoom]
 * requires: [key] is a string of an item's id
 *           [locs] is a location list
 *           [currentRoom] is a room
*)
let rec key_not_in_locations (key:string) (locs: location list) (currentRoom: room) =
  match locs with
  | [] -> true
  | h::t -> if h.item = key && h.room = currentRoom.id then false else key_not_in_locations key t currentRoom

(* [requirements_fulfilled_for_room keyList rString inv locs currentRoom] returns
 * true if all keys in [keyList] can be found in either [inv] or [locs], with
 * supporting information from [rString] and [currentRoom]
 * requires: [keyList] is a string list of item id's
 *           [rString] is a room's id
 *           [inv] is an item list
 *           [locs] is a location list
 *           [currentRoom] is a room
*)
let rec requirements_fulfilled_for_room (keyList: string list) (rString: string) (inv: item list) (locs: location list) (currentRoom: room)=
  match keyList with
  | [] -> true
  | h::t -> if ((key_not_in_inv h inv) && (key_not_in_locations h locs currentRoom)) then
      false else (requirements_fulfilled_for_room t rString inv locs currentRoom)

(* [item_in_current_room itemName r locList] returns true if the item with id
 * [itemName] is in the current room, with information from [locList]
 * requires: [itemName] is a string of an item's id
 *           [r] is a room
 *           [locList] is a location list
*)
let rec item_in_current_room (itemName: string) (r: room) (locList: location list) =
  match locList with
  | [] -> false
  | h::t -> if r.id = h.room && itemName = h.item then true
    else item_in_current_room itemName r t

(* [item_in_inventory itemName inv] returns true if the item with id
 * [itemName] is in the inventory [inv]
 * requires: [itemName] is a string of an item's id
 *           [inv] is an item list
*)
let rec item_in_inventory (itemName: string) (inv: item list) =
  match inv with
  | [] -> false
  | h::t -> if h.id = itemName then true
    else item_in_inventory itemName t

(* [delete_item_from_inv inv iString] deletes the item with id [itemName]
 * from the inventory [inv]
 * requires: [inv] is an item list
 *           [iString] is a string of an item's id
*)
let rec delete_item_from_inv (inv: item list) (iString: string) =
  match inv with
  | [] -> inv
  | h::t -> if h.id = iString then delete_item_from_inv t iString
    else h :: (delete_item_from_inv t iString)

(* [room_description_helper s roomDescs] returns a string of texts describing
 * the current room at state [s], with information from [roomDescs]
 * requires: [s] is a state
 *           [roomDescs] is a description list
*)
let rec room_description_helper (s:state) (roomDescs: description list) =
  match roomDescs with
  | [] -> failwith "Error: Invalid json description format"
  | h::t -> if requirements_fulfilled_for_room h.requires s.current_room.id s.inventory s.item_locations s.current_room
    then h.text else room_description_helper s t

(* [room_description s] calls room_description_helper with state [s]
 * requires: [s] is a state
*)
let room_description s =
  room_description_helper s s.current_room.descriptions

(* [items_in_room_helper s itemLocations finalItemList] returns a string list
 * of the items in the current room at state [s], with information from
 * [itemLocations]
 * requires: [s] is a state
 *           [itemLocations] is a location list of the items in the state
 *           [finalItemList] is a string list representing the item id's in room
*)
let rec items_in_room_helper (s:state) (itemLocations: location list) (finalItemList: string list) =
  match itemLocations with
  | [] -> if List.length finalItemList =0 then "No items in this location"::[]
                                                 else finalItemList
  | h::t -> if h.room = s.current_room.id then
      items_in_room_helper s t (h.item :: finalItemList) else
      items_in_room_helper s t finalItemList

(* [items_in_room s] calls items_in_room_helper with state [s]
 * requires: [s] is a state
*)
let items_in_room s =
  items_in_room_helper s s.item_locations []

(* [win_message_string s] returns the string of the game's win message
 * requires: [s] is a state
*)
let win_message_string s =
  s.game.win_message

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
let do' c (st: state) =
  (
    if c.com = "go" && valid_direction st.current_room.exits c.word &&
      requirements_fulfilled_for_room (get_exit_from_room st.current_room.exits
                        (get_room_from_exit st.current_room.exits c.word)).keys
        (get_room_from_exit st.current_room.exits c.word) (st.inventory)
        (st.item_locations) (st.current_room)
   then
      let newRoomID = get_room_from_exit st.current_room.exits c.word in
      make_state (find_room st.game.rooms newRoomID) (st.inventory)
        (if List.mem newRoomID (st.rooms_visited) then st.points else
           st.points + (find_room st.game.rooms newRoomID).points) (st.turns + 1)
      (newRoomID::st.rooms_visited) (st.item_locations) (st.game)

   else if c.com = "go" && valid_room_from_current st.current_room.exits c.word &&
      requirements_fulfilled_for_room (get_exit_from_room st.current_room.exits
                        c.word).keys
        (c.word) (st.inventory)
        (st.item_locations) (st.current_room)
   then
      make_state (find_room st.game.rooms c.word) (st.inventory)
        (if List.mem c.word (visited st) then st.points else
           st.points + (find_room st.game.rooms c.word).points) (st.turns + 1)
        (c.word::st.rooms_visited) (st.item_locations) (st.game)

  else if c.com = "take" && item_in_current_room c.word st.current_room st.item_locations then
      make_state (st.current_room)
      ((find_item st.game.items c.word) :: st.inventory)
      (if (List.mem c.word st.current_room.treasure) then
         (st.points - an_items_points (st.game.items) (c.word)) else st.points) (st.turns+1) (st.rooms_visited)
      (delete_item_from_locs st.item_locations c.word)
      (st.game)

  else if c.com = "drop" && item_in_inventory c.word st.inventory then
    make_state (st.current_room)
      (delete_item_from_inv st.inventory c.word)
      (if (List.mem c.word st.current_room.treasure) then
         (st.points + an_items_points (st.game.items) (c.word)) else st.points) (st.turns+1) (st.rooms_visited)
      ({room = st.current_room.id; item = c.word;} :: st.item_locations)
      (st.game)

  else if c.com = "quit" then st
  else if c.com = "look" then st
  else if c.com = "inventory" || c.com = "inv" then st
  else if c.com = "score" then st
  else if c.com = "turns" then st
  else st
)
