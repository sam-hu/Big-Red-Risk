type country = {
  country_id: string;
  bordering_countries: string list;
}

type card = Circle | Triangle | Square

type player = {
  player_id: string;
  num_deployed: int;
  num_undeployed: int;
  cards: card list;
  score: int;
}

type continent = {
  countries: country list;
  id: string;
  bonus: int;
}

type board = continent list
