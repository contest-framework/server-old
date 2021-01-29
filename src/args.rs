// command-line arguments

use super::errors::UserErr;

#[derive(Debug, PartialEq)]
pub enum Command {
  Normal,      // normal operation
  Debug,       // print the received commands from the pipe
  Run(String), // run the given string
  Setup,       // create a config file
  Version,     // show the version
}

pub fn parse<I>(mut argv: I) -> Result<Command, UserErr>
where
  I: Iterator<Item = String>,
{
  argv.next(); // skip argv[0]
  let mut mode = Command::Normal;
  loop {
    match argv.next() {
      None => return Ok(mode),
      Some(arg) => match arg.as_str() {
        "debug" => mode = Command::Debug,
        "run" => match argv.next() {
          Some(cmd) => mode = Command::Run(cmd),
          None => {
            return Err(UserErr::new(
              String::from("missing option for \"run\" command"),
              String::from("The \"run\" command requires the command to run"),
            ))
          }
        },
        "setup" => mode = Command::Setup,
        "version" => mode = Command::Version,
        _ => {
          return Err(UserErr::new(
            format!("unknown argument: {}", arg),
            String::from("The arguments are \"debug\" or \"run <command>\"."),
          ))
        }
      },
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn parse_no_args() {
    let give = vec!["tertestrial".to_string()];
    let want = Ok(Command::Normal);
    assert_eq!(parse(give.into_iter()), want);
  }

  #[test]
  fn parse_debug() {
    let give = vec!["tertestrial".to_string(), "debug".to_string()];
    let want = Ok(Command::Debug);
    assert_eq!(parse(give.into_iter()), want);
  }

  #[test]
  fn parse_run_with_arg() {
    let give = vec![
      "tertestrial".to_string(),
      "run".to_string(),
      "my command".to_string(),
    ];
    let want = Ok(Command::Run("my command".to_string()));
    assert_eq!(parse(give.into_iter()), want);
  }

  #[test]
  fn parse_run_without_arg() {
    let give = vec!["tertestrial".to_string(), "run".to_string()];
    let want = Err(UserErr {
      reason: "missing option for \"run\" command".to_string(),
      guidance: "The \"run\" command requires the command to run".to_string(),
    });
    assert_eq!(parse(give.into_iter()), want);
  }

  #[test]
  fn parse_unknown() {
    let give = vec!["tertestrial".to_string(), "zonk".to_string()];
    let want = Err(UserErr {
      reason: "unknown argument: zonk".to_string(),
      guidance: "The arguments are \"debug\" or \"run <command>\".".to_string(),
    });
    assert_eq!(parse(give.into_iter()), want);
  }
}
