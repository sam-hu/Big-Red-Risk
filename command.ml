open Board

type loser = Left|Right|Both

type attack_command = FalseAttack | Attack of (string*string*loser*int)

type fortify_command = FalseFortify | Fortify of string

type reinforce_command = FalseReinforce | Reinforce of string

type trade_command = NoTrade | Same of card | Different
