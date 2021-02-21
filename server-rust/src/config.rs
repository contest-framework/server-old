use super::errors::UserErr;
use super::trigger::Trigger;
use prettytable::Table;
use regex::Regex;
use serde::Deserialize;
use std::vec::Vec;

/// Actions are executed when receiving a trigger.
#[derive(Deserialize, Debug)]
pub struct Action {
  trigger: Trigger,
  run: String,
  vars: Option<Vec<Var>>,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
enum VarSource {
  File,
  Line,
  CurrentOrAboveLineContent,
}

impl std::fmt::Display for VarSource {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    let text = match &self {
      VarSource::File => "file",
      VarSource::Line => "line",
      VarSource::CurrentOrAboveLineContent => "currentOrAboveLineContent",
    };
    write!(f, "{}", text)
  }
}

#[derive(Deserialize, Debug)]
struct Var {
  name: String,
  source: VarSource,
  filter: String,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct Options {
  pub before_run: BeforeRun,
  pub after_run: AfterRun,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct BeforeRun {
  pub clear_screen: bool,
  pub newlines: u8,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AfterRun {
  pub newlines: u8,
  pub indicator_lines: u8,
}

#[derive(Deserialize, Debug)]
pub struct Configuration {
  pub actions: Vec<Action>,
  pub options: Options,
}

pub fn from_file() -> Result<Configuration, UserErr> {
  let file = match std::fs::File::open(".testconfig.json") {
    Ok(config) => config,
    Err(e) => {
      match e.kind() {
        std::io::ErrorKind::NotFound => return Err(UserErr::from_str("Configuration file not found", "Tertestrial requires a configuration file named \".testconfig.json\" in the current directory. Please run \"tertestrial setup \" to create one.")),
        _ => return Err(UserErr::new(format!("Cannot open configuration file: {}", e), "")),
      }
    }
  };
  serde_json::from_reader(file)
    .map_err(|e| UserErr::new(format!("Cannot parse configuration file: {}", e), ""))
}

pub fn create() -> Result<(), UserErr> {
  std::fs::write(
    ".testconfig.json",
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
        "command": "testFunction",
        "file": "\\.ext$",
      },
      "run": "echo testing file {{file}} at line {{line}}"
    }
  ]
}"#,
  )
  .map_err(|e| UserErr::new(format!("cannot create configuration file: {}", e), ""))
}

impl Configuration {
  pub fn get_command(&self, trigger: Trigger) -> Result<String, UserErr> {
    for action in &self.actions {
      if action.trigger.matches_client_trigger(&trigger)? {
        return Ok(self.format_run(&action, &trigger)?);
      }
    }
    Err(UserErr::new(
      format!("cannot determine command for trigger: {}", trigger),
      "Please make sure that this trigger is listed in your configuration file",
    ))
  }

  /// replaces all placeholders in the given run string
  fn format_run(&self, action: &Action, trigger: &Trigger) -> Result<String, UserErr> {
    let mut values: std::collections::HashMap<&str, String> = std::collections::HashMap::new();
    values.insert("command", trigger.command.clone());
    if trigger.file.is_some() {
      values.insert("file", trigger.file.as_ref().unwrap().clone());
    }
    if trigger.line.is_some() {
      values.insert("line", trigger.line.unwrap().to_string());
    }
    if action.vars.is_some() {
      for var in action.vars.as_ref().unwrap() {
        values.insert(&var.name, calculate_var(&var, &values)?);
      }
    }
    let mut replaced = action.run.clone();
    for (placeholder, replacement) in values {
      replaced = replace(&replaced, placeholder, &replacement);
    }
    Ok(replaced)
  }
}

impl std::fmt::Display for Configuration {
  fn fmt(&self, _f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    let mut table = Table::new();
    table.add_row(prettytable::row!["TRIGGER", "RUN"]);
    for action in &self.actions {
      table.add_row(prettytable::row![format!("{}", action.trigger), action.run]);
    }
    table.printstd();
    println!("Options:");
    println!(
      "- beforeRun.clearScreen: {}",
      self.options.before_run.clear_screen
    );
    Ok(())
  }
}

fn calculate_var(
  var: &Var,
  values: &std::collections::HashMap<&str, String>,
) -> Result<String, UserErr> {
  match var.source {
    VarSource::File => filter(values.get("file").unwrap(), &var.filter),
    VarSource::Line => filter(values.get("line").unwrap(), &var.filter),
    VarSource::CurrentOrAboveLineContent => {
      let file_name = values.get("file").unwrap();
      let file_content = std::fs::read_to_string(file_name).unwrap();
      let lines: Vec<&str> = file_content.split('\n').collect();
      let re = Regex::new(&var.filter).unwrap();
      let mut line: u32 = values.get("line").unwrap().parse().unwrap();
      while line > 0 {
        line -= 1;
        let line_text: String = lines.get(line as usize).unwrap().to_string();
        let captures = re.captures(&line_text);
        if captures.is_none() {
          // no match on this line --> try the one above
          continue;
        }
        let captures = captures.unwrap();
        if captures.len() > 2 {
          return Err(UserErr::new(
            format!(
              "found too many captures using regex \"{}\" on line: {}",
              &var.filter, &line_text
            ),
            "filters in the Tertestrial configuration file can only contain one capture group",
          ));
        }
        return Ok(captures.get(1).unwrap().as_str().to_string());
      }
      Err(UserErr::new(
        format!("Did not find pattern {} in file {}", &var.filter, file_name),
        "Please check that the file .testconfig.json is correct",
      ))
    }
  }
}

fn filter(text: &str, filter: &str) -> Result<String, UserErr> {
  let re = regex::Regex::new(filter).unwrap();
  let captures = re.captures(text).unwrap();
  if captures.len() != 2 {
    return Err(UserErr::new(
      format!(
        "found {} captures using filter \"{}\"",
        captures.len(),
        text
      ),
      "filters in the Tertestrial configuration file can only contain one capture group",
    ));
  }
  return Ok(captures.get(1).unwrap().as_str().to_string());
}

fn replace(text: &str, placeholder: &str, replacement: &str) -> String {
  regex::Regex::new(&format!("\\{{\\{{\\s*{}\\s*\\}}\\}}", placeholder))
    .unwrap()
    .replace_all(text, regex::NoExpand(replacement))
    .to_string()
}

//
// ----------------------------------------------------------------------------
//

#[cfg(test)]
mod tests {

  #[cfg(test)]
  mod get_command {
    use super::super::*;

    #[test]
    fn test_all() {
      let config = Configuration {
        actions: vec![],
        options: Options {
          before_run: BeforeRun {
            clear_screen: false,
            newlines: 0,
          },
          after_run: AfterRun {
            newlines: 0,
            indicator_lines: 0,
          },
        },
      };
      let give = Trigger {
        command: "testAll".to_string(),
        file: None,
        line: None,
      };
      let have = config.get_command(give);
      assert!(have.is_err());
    }

    #[test]
    fn exact_match() {
      let action1 = Action {
        trigger: Trigger {
          command: "testFunction".to_string(),
          file: Some("filename".to_string()),
          line: Some(1),
        },
        run: String::from("action1 command"),
        vars: Some(vec![]),
      };
      let action2 = Action {
        trigger: Trigger {
          command: "testFunction".to_string(),
          file: Some("filename".to_string()),
          line: Some(2),
        },
        run: String::from("action2 command"),
        vars: Some(vec![]),
      };
      let action3 = Action {
        trigger: Trigger {
          command: "testFunction".to_string(),
          file: Some("filename".to_string()),
          line: Some(3),
        },
        run: String::from("action3 command"),
        vars: Some(vec![]),
      };
      let config = Configuration {
        actions: vec![action1, action2, action3],
        options: Options {
          before_run: BeforeRun {
            clear_screen: false,
            newlines: 0,
          },
          after_run: AfterRun {
            newlines: 0,
            indicator_lines: 0,
          },
        },
      };
      let give = Trigger {
        command: "testFunction".to_string(),
        file: Some("filename".to_string()),
        line: Some(2),
      };
      let have = config.get_command(give);
      assert_eq!(have, Ok(String::from("action2 command")));
    }

    #[test]
    fn no_match() {
      let action1 = Action {
        trigger: Trigger {
          command: "testFile".to_string(),
          file: Some("filename".to_string()),
          line: None,
        },
        run: String::from("action1 command"),
        vars: Some(vec![]),
      };
      let config = Configuration {
        actions: vec![action1],
        options: Options {
          before_run: BeforeRun {
            clear_screen: false,
            newlines: 0,
          },
          after_run: AfterRun {
            newlines: 0,
            indicator_lines: 0,
          },
        },
      };
      let give = Trigger {
        command: "testFile".to_string(),
        file: Some("other filename".to_string()),
        line: None,
      };
      let have = config.get_command(give);
      assert!(have.is_err());
    }
  }

  #[cfg(test)]
  mod replace {
    use super::super::*;

    #[test]
    fn tight_placeholder() {
      let have = replace("hello {{world}}", "world", "universe");
      assert_eq!(have, "hello universe");
    }

    #[test]
    fn loose_placeholder() {
      let have = replace("hello {{ world }}", "world", "universe");
      assert_eq!(have, "hello universe");
    }

    #[test]
    fn multiple_placeholders() {
      let have = replace("{{ hello }} {{ hello }}", "hello", "bye");
      assert_eq!(have, "bye bye");
    }
  }
}
