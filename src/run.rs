pub fn run(cmd: String) {
  println!("received line: {}", cmd);
  let status = std::process::Command::new("/bin/cat")
    .arg("README.md")
    .status()
    .expect("failed to execute process");
  println!("process exited with: {}", status);
  assert!(status.success());
}
