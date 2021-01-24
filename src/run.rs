// pub struct Runner {
//   config
// }

pub enum Outcome {
  TestPass,
  TestFail,
  NotFound,
}

pub fn run(cmd: &String) -> Outcome {
  println!("executing: {}", cmd);
  let words = shellwords::split(&cmd).unwrap();
  let (cmd, args) = words.split_at(1);
  match std::process::Command::new(&cmd[0]).args(args).status() {
    Ok(exit_status) => {
      if exit_status.success() {
        return Outcome::TestPass;
      } else {
        return Outcome::TestFail;
      }
    }
    Err(_) => Outcome::NotFound,
  }
}
