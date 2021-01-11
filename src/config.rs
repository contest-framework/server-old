use serde::Deserialize;

// Possible patterns received from the client.
// enum Scope {
//   All,
//   File(String),
//   LineInFile(String, u32),
// }

#[derive(Deserialize, Debug)]
pub struct Trigger {
  filename: Option<String>,
  line: Option<String>,
}

// Actions are executed when receiving a pattern.
#[derive(Deserialize, Debug)]
pub struct Action {
  trigger: Trigger,
  run: String,
}

#[derive(Deserialize, Debug)]
pub struct Configuration {
  actions: Vec<Action>,
}

pub fn from_file() -> Configuration {
  let file = std::fs::File::open("tertestrial.json").expect("Cannot open file");
  let c: Configuration = serde_json::from_reader(file).expect("cannot read JSON");
  c
}
