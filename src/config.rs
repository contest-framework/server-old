use super::trigger::Trigger;
use prettytable::Table;
use serde::Deserialize;

// Actions are executed when receiving a trigger.
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
  let file = std::fs::File::open("tertestrial.json").expect("Cannot find configuration file");
  serde_json::from_reader(file).expect("cannot read JSON")
}

pub fn create() -> Result<(), std::io::Error> {
  std::fs::write(
    "tertestrial.json",
    r#"{
  "actions": [
    {
      "trigger": {},
      "run": "echo test all files"
    },

    {
      "trigger": { "filename": ".rs$" },
      "run": "echo testing file {{filename}}"
    },

    {
      "trigger": {
        "filename": ".ext$",
        "line": "d+"
      },
      "run": "echo testing file {{filename}} at line {{line}}"
    }
  ]
}"#,
  )
}

impl Configuration {
  pub fn get_command(&self, trigger: Trigger) -> Option<&String> {
    for action in &self.actions {
      if action.trigger == trigger {
        return Some(&action.run);
      }
    }
    None
  }
}

impl std::fmt::Display for Configuration {
  fn fmt(&self, _f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    let mut table = Table::new();
    table.add_row(prettytable::row!["TRIGGER", "RUN"]);
    for action in self.actions.iter() {
      table.add_row(prettytable::row![format!("{}", action.trigger), action.run]);
    }
    table.printstd();
    Ok(())
  }
}

//
// ----------------------------------------------------------------------------
//

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn config_get_command_empty() {
    let config = Configuration { actions: vec![] };
    let give = Trigger {
      filename: None,
      line: None,
      name: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, None);
  }

  #[test]
  fn config_get_command_multiple_actions() {
    let action1 = Action {
      trigger: Trigger {
        filename: Some(String::from("matching filename")),
        line: Some(String::from("2")),
        name: None,
      },
      run: String::from("action1 command"),
    };
    let action2 = Action {
      trigger: Trigger {
        filename: Some(String::from("matching filename")),
        line: None,
        name: None,
      },
      run: String::from("action2 command"),
    };
    let action3 = Action {
      trigger: Trigger {
        filename: Some(String::from("other filename")),
        line: None,
        name: None,
      },
      run: String::from("action3 command"),
    };
    let config = Configuration {
      actions: vec![action1, action2, action3],
    };
    let give = Trigger {
      filename: Some(String::from("matching filename")),
      line: None,
      name: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, Some(&String::from("action2 command")));
  }

  #[test]
  fn config_get_command_no_match() {
    let action1 = Action {
      trigger: Trigger {
        filename: Some(String::from("matching filename")),
        line: None,
        name: None,
      },
      run: String::from("action1 command"),
    };
    let config = Configuration {
      actions: vec![action1],
    };
    let give = Trigger {
      filename: Some(String::from("other filename")),
      line: None,
      name: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, None);
  }
}
