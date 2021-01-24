// pub struct Runner {
//   config
// }

pub enum Outcome {
  TestPass(),
  TestFail(),
  NotFound(String),
}

pub fn run(command: &String) -> Outcome {
  println!("executing: {}", command);
  let argv = shellwords::split(&command).unwrap();
  let (cmd, args) = argv.split_at(1);
  match std::process::Command::new(&cmd[0]).args(args).status() {
    Err(_) => Outcome::NotFound(command.to_string()),
    Ok(exit_status) => match exit_status.success() {
      true => Outcome::TestPass(),
      false => Outcome::TestFail(),
    },
  }
}
