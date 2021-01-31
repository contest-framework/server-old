use std::error::Error;

#[derive(Debug, PartialEq)]
pub struct UserErr {
  pub reason: String,
  pub guidance: String,
}

impl UserErr {
  pub fn new(reason: String, guidance: String) -> UserErr {
    UserErr { reason, guidance }
  }
}

impl Error for UserErr {}

impl std::fmt::Display for UserErr {
  fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
    write!(
      f,
      "Please fix this mistake: {}\n\n{}",
      self.reason, self.guidance
    )
  }
}
