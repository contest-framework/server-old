// pub struct Runner {
//   config
// }

pub fn run(cmd: &String) {
  println!("executing: {}", cmd);
  let words = shellwords::split(&cmd).unwrap();
  let (cmd, args) = words.split_at(1);
  let status = std::process::Command::new(&cmd[0])
    .args(args)
    .status()
    .expect("failed to execute process");
  println!("process exited with: {}", status);
}
