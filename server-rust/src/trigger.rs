//! commands sent over the FIFO

use super::errors::UserErr;
use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq)]
pub struct Trigger {
  pub command: String,
  pub file: Option<String>,
  pub line: Option<u32>,
}

impl Trigger {
  pub fn matches_client_trigger(&self, from_client: &Trigger) -> Result<bool, UserErr> {
    if self.command != from_client.command {
      return Ok(false);
    }
    if self.line.is_none() && from_client.line.is_some() {
      // client sent line but config doesn't contain it --> still a match
      return Ok(true);
    }
    if self.line != from_client.line {
      return Ok(false);
    }
    if self.file.is_none() && from_client.file.is_none() {
      return Ok(true);
    }
    if self.file.is_some() && from_client.file.is_some() {
      let self_file = &self.file.as_ref().unwrap();
      let pattern = glob::Pattern::new(&self_file).map_err(|e| {
        UserErr::new(
          format!("Invalid glob pattern: {}", &self_file),
          &e.to_string(),
        )
      })?;
      return Ok(pattern.matches(from_client.file.as_ref().unwrap()));
    }
    Ok(false)
  }
}

impl std::fmt::Display for Trigger {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    write!(f, "{{")?;
    let mut parts: std::vec::Vec<String> = std::vec::Vec::new();
    parts.push(format!("\"command\": \"{}\"", self.command));
    if self.file.is_some() {
      parts.push(format!("\"file\": \"{}\"", self.file.as_ref().unwrap()));
    }
    if self.line.is_some() {
      parts.push(format!("\"line\": \"{}\"", self.line.as_ref().unwrap()));
    }
    write!(f, "{}", parts.join(", "))?;
    write!(f, " }}")
  }
}

pub fn from_string(line: &str) -> Result<Trigger, UserErr> {
  match serde_json::from_str(&line) {
    Ok(trigger) => Ok(trigger),
    Err(err) => Err(UserErr::new(
      format!("cannot parse command received from client: {}", line),
      &format!(
        "This is a problem with your Tertestrial client.\n\nError message from JSON parser: {}",
        err
      ),
    )),
  }
}

//
// ----------------------------------------------------------------------------
//

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn from_line_test_all() {
    let have = from_string(r#"{ "command": "testAll" }"#).unwrap();
    let want = Trigger {
      command: "testAll".to_string(),
      file: None,
      line: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename() {
    let have = from_string(r#"{ "command": "testFile", "file": "foo.rs" }"#).unwrap();
    let want = Trigger {
      command: "testFile".to_string(),
      file: Some("foo.rs".to_string()),
      line: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename_line() {
    let have =
      from_string(r#"{ "command": "testFunction", "file": "foo.rs", "line": 12 }"#).unwrap();
    let want = Trigger {
      command: "testFunction".to_string(),
      file: Some("foo.rs".to_string()),
      line: Some(12),
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename_extra_fields() {
    let have =
      from_string(r#"{ "command": "testFile", "file": "foo.rs", "other": "12" }"#).unwrap();
    let want = Trigger {
      command: "testFile".to_string(),
      file: Some(String::from("foo.rs")),
      line: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_invalid_json() {
    let have = from_string("{\"filename}");
    let want = UserErr::from_str("cannot parse command received from client: {\"filename}", "This is a problem with your Tertestrial client.\n\nError message from JSON parser: EOF while parsing a string at line 1 column 11");
    match have {
      Ok(_) => panic!("this shouldn't work"),
      Err(err) => assert_eq!(err, want),
    }
  }

  #[test]
  fn eq_match() {
    let trigger1 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    assert!(trigger1 == trigger2);
  }

  #[test]
  fn eq_mismatching_filename() {
    let trigger1 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename1".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename2".to_string()),
      line: Some(12),
    };
    assert!(trigger1 != trigger2);
  }

  #[test]
  fn eq_mismatching_line() {
    let trigger1 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(11),
    };
    assert!(trigger1 != trigger2);
  }

  #[test]
  fn matches_match() {
    let config = Trigger {
      command: "testFunction".to_string(),
      file: Some("**/*.rs".to_string()),
      line: Some(12),
    };
    let give = Trigger {
      command: "testFunction".to_string(),
      file: Some("foo.rs".to_string()),
      line: Some(12),
    };
    assert!(config.matches_client_trigger(&give).unwrap());
    let give = Trigger {
      command: "testFunction".to_string(),
      file: Some("foo/bar.rs".to_string()),
      line: Some(12),
    };
    assert!(config.matches_client_trigger(&give).unwrap());
  }

  #[test]
  fn matches_mismatching_command() {
    let config = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let give = Trigger {
      command: "testFile".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    assert!(!config.matches_client_trigger(&give).unwrap());
  }

  #[test]
  fn matches_mismatching_file() {
    let config = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let give = Trigger {
      command: "testFile".to_string(),
      file: Some("filename2".to_string()),
      line: Some(12),
    };
    assert!(!config.matches_client_trigger(&give).unwrap());
  }

  #[test]
  fn matches_mismatching_line() {
    let config = Trigger {
      command: "testFunction".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let give = Trigger {
      command: "testFile".to_string(),
      file: Some("filename".to_string()),
      line: Some(11),
    };
    assert!(!config.matches_client_trigger(&give).unwrap());
  }
}
