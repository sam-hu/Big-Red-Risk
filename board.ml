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
  ai: bool;
  ratio: float
}

type continent = {
  countries: country list;
  id: string;
  bonus: int;
}

type board = continent list

let p1 = {
  player_id = "Player one";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}

let p2 = {
  player_id = "Player two";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}

let p3 = {
  player_id = "Player three";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}

let p4 = {
  player_id = "Player four";
  num_deployed = 0;
  num_undeployed = 0;
  cards = [];
  ai = false;
  ratio = 0.0
}


let becker = {
  country_id = "Becker";
  bordering_countries = ["Cook";"Rose"]
}

let rose = {
  country_id = "Rose";
  bordering_countries = ["Keeton";"Bethe";"Becker"]
}

let keeton = {
  country_id = "Keeton";
  bordering_countries = ["Rose";"Bethe"]
}

let bethe = {
  country_id = "Bethe";
  bordering_countries = ["Keeton";"Rose";"Uris"]
}

let cook = {
  country_id = "Cook";
  bordering_countries = ["Becker";"Morrill"]
}

let morrill = {
  country_id = "Morrill";
  bordering_countries = ["Uris";"Tjaden";"Cook"]
}

let uris = {
  country_id = "Uris";
  bordering_countries = ["Bethe";"Morrill";"Olin"; "Sibley"]
}

let tjaden = {
  country_id = "Tjaden";
  bordering_countries = ["Morrill";"Goldwin";"Sibley"]
}

let olin = {
  country_id = "Olin";
  bordering_countries = ["Uris";"Cascadilla";"Goldwin"]
}

let goldwin = {
  country_id = "Goldwin";
  bordering_countries = ["Olin";"Tjaden";"Klarman"]
}

let sibley = {
  country_id = "Sibley";
  bordering_countries = ["Donlon";"Tjaden";"Klarman";"Uris"]
}

let klarman = {
  country_id = "Klarman";
  bordering_countries = ["Sibley";"Goldwin";"Dairy Bar"]
}

let donlon = {
  country_id = "Donlon";
  bordering_countries = ["Townhouses";"RPCC";"Sibley";"Appel"]
}

let townhouses = {
  country_id = "Townhouses";
  bordering_countries = ["Donlon";"RPCC"]
}

let rpcc = {
  country_id = "RPCC";
  bordering_countries = ["Townhouses";"Donlon";"Low Rise"]
}

let lowrise = {
  country_id = "Low Rise";
  bordering_countries = ["RPCC";"Appel"]
}

let appel = {
  country_id = "Appel";
  bordering_countries = ["Donlon";"Mann";"Low Rise"]
}

let mann = {
  country_id = "Mann";
  bordering_countries = ["Appel";"Dairy Bar";"Riley"]
}

let riley = {
  country_id = "Riley";
  bordering_countries = ["Gates";"Dairy Bar";"Mann"]
}

let dairy = {
  country_id = "Dairy Bar";
  bordering_countries = ["Klarman";"Riley";"Mann"]
}

let gates = {
  country_id = "Gates";
  bordering_countries = ["Riley";"Schwartz"]
}

let cascadilla = {
  country_id = "Cascadilla";
  bordering_countries = ["Sheldon";"Olin";"Schwartz"]
}

let sheldon = {
  country_id = "Sheldon";
  bordering_countries = ["Cascadilla";"Schwartz"]
}

let schwartz = {
  country_id = "Schwartz";
  bordering_countries = ["Sheldon";"Cascadilla";"Gates"]
}


let west = {
  countries = [becker; cook; rose; keeton; bethe];
  id = "West Campus";
  bonus = 5;
}

let central = {
  countries = [uris; tjaden; morrill; sibley; goldwin; klarman; olin];
  id = "Central Campus";
  bonus = 8;
}

let north = {
  countries = [townhouses; donlon; rpcc; lowrise; appel];
  id = "North Campus";
  bonus = 6;
}

let ag_quad = {
  countries = [mann; dairy; riley; gates];
  id = "Ag. Quad";
  bonus = 4;
}

let collegetown = {
  countries = [cascadilla; sheldon; schwartz];
  id = "Collegetown";
  bonus = 3;
}

let graphboard = [west; north; central; ag_quad; collegetown]
