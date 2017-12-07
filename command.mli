open Board

(*[trade_command] is NoTrade if the player cannot trade in any cards, Same c
  if the player can trade in 3 cards of type [c], or Different if the player
  can trade in 3 cards of different types *)
type trade_command = NoTrade | Same of card | Different

(*[reinforce_command] is FalseReinforce if the player cannot reinforce, or
  Reinforce s if the player can reinforce the country with country_id [s]*)
type reinforce_command = FalseReinforce | Reinforce of string

(*[loser] is Left if the the attacking country loses the battle, Right if the
  defending country loses the battle, or Both if there is a draw *)
type loser = Left|Right|Both

(*[attack_command] is FalseAttack if the player cannot attack, or
  Attack (s1, s2, l, i) if country [s1] attacked country [s2], with l being
  Left if [s1] lost, Right if [s2] lost, or Both if both countries lost, and i
  being the number of troops the loser(s) lost as a result of the battle *)
type attack_command = FalseAttack | Attack of (string*string*loser*int)

(*[fortify_command] is FalseFortify if the player cannot fortify, or Fortify s
  if the player can fortify the country with country_id [s] *)
type fortify_command = FalseFortify | Fortify of string
