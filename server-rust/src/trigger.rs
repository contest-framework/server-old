use super::errors::UserErr;
use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq)]
pub struct Trigger {
  pub filename: Option<String>,
  pub line: Option<String>,
  pub name: Option<String>,
}

impl std::fmt::Display for Trigger {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    write!(f, "{{")?;
    if self.filename.is_some() {
      write!(f, "\"filename\": \"{}\"", self.filename.as_ref().unwrap())?;
    }
    if self.line.is_some() {
      write!(f, "\"line\": \"{}\"", self.line.as_ref().unwrap())?;
    }
    if self.name.is_some() {
      write!(f, "\"name\": \"{}\"", self.name.as_ref().unwrap())?;
    }
    write!(f, "}}")
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
  fn from_line_empty() {
    let have = from_line(&String::from("{}")).unwrap();
    let want = Trigger {
      filename: None,
      line: None,
      name: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename() {
    let have = from_line(&String::from("{\"filename\": \"foo.rs\"}")).unwrap();
    let want = Trigger {
      filename: Some(String::from("foo.rs")),
      line: None,
      name: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename_line() {
    let have = from_line(&String::from(
      "{\"filename\": \"foo.rs\", \"line\": \"12\"}",
    ))
    .unwrap();
    let want = Trigger {
      filename: Some(String::from("foo.rs")),
      line: Some(String::from("12")),
      name: None,
    };
    assert_eq!(have, want);
  }

  #[test]
  fn from_line_filename_extra_fields() {
    let have = from_line(&String::from(
      "{\"filename\": \"foo.rs\", \"other\": \"12\"}",
    ))
    .unwrap();
    let want = Trigger {
      filename: Some(String::from("foo.rs")),
      line: None,
      name: None,
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
      filename: Some(String::from("filename")),
      line: Some(String::from("line")),
      name: None,
    };
    let trigger2 = Trigger {
      filename: Some(String::from("filename")),
      line: Some(String::from("line")),
      name: None,
    };
    assert!(trigger1 == trigger2);
  }

  #[test]
  fn trigger_eq_mismatching_filename() {
    let trigger1 = Trigger {
      filename: Some(String::from("filename 1")),
      line: Some(String::from("line")),
      name: None,
    };
    let trigger2 = Trigger {
      filename: Some(String::from("filename 2")),
      line: Some(String::from("line")),
      name: None,
    };
    assert!(trigger1 != trigger2);
  }

  #[test]
  fn trigger_eq_mismatching_line() {
    let trigger1 = Trigger {
      filename: Some(String::from("filename")),
      line: Some(String::from("line 1")),
      name: None,
    };
    let trigger2 = Trigger {
      filename: Some(String::from("filename")),
      line: Some(String::from("line 2")),
      name: None,
    };
    assert!(trigger1 != trigger2);
  }

  #[test]
  fn trigger_eq_missing_line() {
    let trigger1 = Trigger {
      filename: Some(String::from("filename")),
      line: Some(String::from("line 1")),
      name: None,
    };
    let trigger2 = Trigger {
      filename: Some(String::from("filename")),
      line: None,
      name: None,
    };
    assert!(trigger1 != trigger2);
  }
}
