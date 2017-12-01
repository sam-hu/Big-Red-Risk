type country = {
  country_id: string;
  bordering_countries: country list;
  num_troops: int;
  occupier: player;
}
and player = {
  player_id: string;
  num_deployed: int;
  num_undeployed: int;
  occupied_countries: country list;
  occupied_continents: continent list;
  cards: card list;
  score: int;
}
and continent = {
  countries: country list;
  id: string;
}
and card = Circle | Triangle | Square

type board = continent list
