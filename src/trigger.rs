use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq)]
pub struct Trigger {
  pub filename: Option<String>,
  pub line: Option<String>,
}

pub fn from_line(line: String) -> Trigger {
  serde_json::from_str(&line).expect("cannot parse line")
}

//
// ----------------------------------------------------------------------------
//

#[test]
fn parse_line_empty() {
  let have = from_line(String::from("{}"));
  let want = Trigger {
    filename: None,
    line: None,
  };
  assert_eq!(have, want);
}

#[test]
fn parse_line_filename() {
  let have = from_line(String::from("{\"filename\": \"foo.rs\"}"));
  let want = Trigger {
    filename: Some(String::from("foo.rs")),
    line: None,
  };
  assert_eq!(have, want);
}

#[test]
fn parse_line_filename_line() {
  let have = from_line(String::from("{\"filename\": \"foo.rs\", \"line\": \"12\"}"));
  let want = Trigger {
    filename: Some(String::from("foo.rs")),
    line: Some(String::from("12")),
  };
  assert_eq!(have, want);
}

#[test]
fn parse_line_filename_extra_fields() {
  let have = from_line(String::from(
    "{\"filename\": \"foo.rs\", \"other\": \"12\"}",
  ));
  let want = Trigger {
    filename: Some(String::from("foo.rs")),
    line: None,
  };
  assert_eq!(have, want);
}

// #[test]
// fn parse_line_invalid_json() {
//   let have = from_line(String::from("{\"filename}"));
//   let want = Trigger {
//     filename: Some(String::from("foo.rs")),
//     line: None,
//   };
//   assert_eq!(have, want);
// }

#[test]
fn trigger_eq_match() {
  let trigger1 = Trigger {
    filename: Some(String::from("filename")),
    line: Some(String::from("line")),
  };
  let trigger2 = Trigger {
    filename: Some(String::from("filename")),
    line: Some(String::from("line")),
  };
  assert!(trigger1 == trigger2);
}

#[test]
fn trigger_eq_mismatching_filename() {
  let trigger1 = Trigger {
    filename: Some(String::from("filename 1")),
    line: Some(String::from("line")),
  };
  let trigger2 = Trigger {
    filename: Some(String::from("filename 2")),
    line: Some(String::from("line")),
  };
  assert!(trigger1 != trigger2);
}

#[test]
fn trigger_eq_mismatching_line() {
  let trigger1 = Trigger {
    filename: Some(String::from("filename")),
    line: Some(String::from("line 1")),
  };
  let trigger2 = Trigger {
    filename: Some(String::from("filename")),
    line: Some(String::from("line 2")),
  };
  assert!(trigger1 != trigger2);
}

#[test]
fn trigger_eq_missing_line() {
  let trigger1 = Trigger {
    filename: Some(String::from("filename")),
    line: Some(String::from("line 1")),
  };
  let trigger2 = Trigger {
    filename: Some(String::from("filename")),
    line: None,
  };
  assert!(trigger1 != trigger2);
}
