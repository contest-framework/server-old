use serde::{Deserialize, Serialize};

// Possible patterns received from the client.
// enum Scope {
//   All,
//   File(String),
//   LineInFile(String, u32),
// }

#[derive(Serialize, Deserialize, Debug)]
pub struct Trigger {
  filename: Option<String>,
  line: Option<String>,
}

// Actions are executed when receiving a trigger.
#[derive(Serialize, Deserialize, Debug)]
pub struct Action {
  trigger: Trigger,
  run: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Configuration {
  actions: Vec<Action>,
}

pub fn from_file() -> Configuration {
  let file = std::fs::File::open("tertestrial.json").expect("Cannot open file");
  let c: Configuration = serde_json::from_reader(file).expect("cannot read JSON");
  c
}

impl Configuration {
  fn get_command(&self, trigger: Trigger) -> Option<String> {
    for action in self.actions {
      if action == trigger {
        return Some(action.run);
      }
    }
    None
  }
}

//________________________________________________________________________________________

mod tests {

  use super::*;

  #[test]
  fn no_actions() {
    let config = Configuration { actions: vec![] };
    let give = Trigger {
      filename: None,
      line: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, None);
  }
}
