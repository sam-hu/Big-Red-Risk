open Board
open Risk_state

type ai = player

(*[ai_next_initial_reinforce st] returns the country_id of the next country in
  st that the AI next wishes to reinforce in the initial reinforcement stage *)
val ai_next_initial_reinforce : state -> string

(*[ai_next_fortify st] returns the country_id of the next country that the AI
  wants to reinforce in st *)
val ai_next_reinforce : state -> string

(*[ai_next_attack st] returns a tuple (c1, c2) where c1 is the country_id of the
  next country that the AI wants to attack from and c2 is the next country that
  the AI wants to attack to in st *)
val ai_next_attack : state -> (string*string)

(*[ai_next_reinforce_after_attack st country_id1 country_id2] is the next
  country, either [country_id1] of [country_id2], that the AI wishes to
  reinforce after an attack from [country_id1] to [country_id2]
  requires: [country_id1] is occupied by the AI and [country_id2] is not *)
val ai_next_reinforce_after_attack : state -> string -> string -> string

(*[ai_next_fortify st] returns the country_id of the next country that the AI
  wants to fortify in st *)
val ai_next_fortify : state -> string

val get_my_countries : ai -> (Board.country*Board.player*int) list -> (Board.country*Board.player*int) list -> (Board.country*Board.player*int) list

(*The following are profiles for players that will be controlled by AIs
  initialized to default values *)
val ai1: ai

val ai2: ai

val ai3: ai

val ai4: ai
