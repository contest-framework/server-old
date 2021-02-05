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
  let file = std::fs::File::open(".testconfig.json").expect("Cannot find configuration file");
  serde_json::from_reader(file).expect("cannot read JSON")
}

pub fn create() -> Result<(), std::io::Error> {
  std::fs::write(
    "tertestrial.json",
    r#"{
  "actions": [
    {
      "trigger": { "command": "testAll" },
      "run": "echo test all files"
    },

    {
      "trigger": {
        "command": "testFile",
        "file": "\\.rs$"
      },
      "run": "echo testing file {{file}}"
    },

    {
      "trigger": {
        "command": "testLine",
        "file": "\\.ext$",
      },
      "run": "echo testing file {{file}} at line {{line}}"
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
  fn get_command_test_all() {
    let config = Configuration { actions: vec![] };
    let give = Trigger {
      command: "testAll".to_string(),
      file: None,
      line: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, None);
  }

  #[test]
  fn get_command_match() {
    let action1 = Action {
      trigger: Trigger {
        command: "testLine".to_string(),
        file: Some("filename".to_string()),
        line: Some(1),
      },
      run: String::from("action1 command"),
    };
    let action2 = Action {
      trigger: Trigger {
        command: "testLine".to_string(),
        file: Some("filename".to_string()),
        line: Some(2),
      },
      run: String::from("action2 command"),
    };
    let action3 = Action {
      trigger: Trigger {
        command: "testLine".to_string(),
        file: Some("filename".to_string()),
        line: Some(3),
      },
      run: String::from("action3 command"),
    };
    let config = Configuration {
      actions: vec![action1, action2, action3],
    };
    let give = Trigger {
      command: "testLine".to_string(),
      file: Some("filename".to_string()),
      line: Some(2),
    };
    let have = config.get_command(give);
    assert_eq!(have, Some(&String::from("action2 command")));
  }

  #[test]
  fn config_get_command_no_match() {
    let action1 = Action {
      trigger: Trigger {
        command: "testFile".to_string(),
        file: Some("filename".to_string()),
        line: None,
      },
      run: String::from("action1 command"),
    };
    let config = Configuration {
      actions: vec![action1],
    };
    let give = Trigger {
      command: "testFile".to_string(),
      file: Some("other filename".to_string()),
      line: None,
    };
    let have = config.get_command(give);
    assert_eq!(have, None);
  }
}
