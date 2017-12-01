open Board

type attack_command = {
  from_noun: string;
  to_noun: string;
}

type fortify_command = {
  from_noun : string;
  to_noun : string;
}

type reinforce_command = string

type pass_command = string

type trade_command = Same of card | Different
