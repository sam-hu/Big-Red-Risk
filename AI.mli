open Board
open Risk_state

val ai_next_initial_reinforce : state -> string

val ai_next_reinforce : state -> string

val ai_next_attack : state -> (string*string)

val ai_next_reinforce_after_attack : state -> string -> string -> string

val ai_next_fortify : state -> string
