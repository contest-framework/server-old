use super::errors::UserErr;
use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq)]
pub struct Trigger {
  pub command: String,
  pub file: Option<String>,
  pub line: Option<u32>,
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

pub fn from_line(line: &str) -> Result<Trigger, UserErr> {
  match serde_json::from_str(&line) {
    Ok(trigger) => Ok(trigger),
    Err(err) => Err(UserErr::new(
      format!("cannot parse command received from client: {}", line),
      format!(
        "Error message from JSON parser: {}\nThis is a problem with your Tertestrial client.",
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
    let have = from_line("{ \"command\": \"testAll\" }").unwrap();
    let want = Trigger {
      command: "testAll".to_string(),
      file: None,
      line: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename() {
    let have = from_line("{ \"command\": \"testFile\", \"file\": \"foo.rs\" }").unwrap();
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
      from_line("{ \"command\": \"testLine\", \"file\": \"foo.rs\", \"line\": 12 }").unwrap();
    let want = Trigger {
      command: "testLine".to_string(),
      file: Some("foo.rs".to_string()),
      line: Some(12),
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename_extra_fields() {
    let have = from_line(&String::from(
      "{ \"command\": \"testFile\", \"file\": \"foo.rs\", \"other\": \"12\"}",
    ))
    .unwrap();
    let want = Trigger {
      command: "testFile".to_string(),
      file: Some(String::from("foo.rs")),
      line: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_invalid_json() {
    let have = from_line(&String::from("{\"filename}"));
    let want = UserErr::new(
    String::from("cannot parse command received from client: {\"filename}"),
    String::from("Error message from JSON parser: EOF while parsing a string at line 1 column 11\nThis is a problem with your Tertestrial client."),
  );
    match have {
      Ok(_) => panic!("this shouldn't work"),
      Err(err) => assert_eq!(err, want),
    }
  }

  #[test]
  fn trigger_eq_match() {
    let trigger1 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    assert!(trigger1 == trigger2);
  }

  #[test]
  fn trigger_eq_mismatching_filename() {
    let trigger1 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename1".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename2".to_string()),
      line: Some(12),
    };
    assert!(trigger1 != trigger2);
  }

  #[test]
  fn trigger_eq_mismatching_line() {
    let trigger1 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename".to_string()),
      line: Some(12),
    };
    let trigger2 = Trigger {
      command: "testLine".to_string(),
      file: Some("filename".to_string()),
      line: Some(11),
    };
    assert!(trigger1 != trigger2);
  }
}
