// This file contains code to manage the FIFO pipe and read from it.

use super::signal::Signal;
use std::io::prelude::*;

use std::sync::Arc;

// A fifo pipe
#[derive(Debug)]
pub struct Pipe {
  pub filepath: std::path::PathBuf,
}

impl Pipe {
  pub fn create(&self) {
    nix::unistd::mkfifo(&self.filepath, nix::sys::stat::Mode::S_IRWXU).expect("cannot create pipe");
  }

  pub fn delete(&self) {
    std::fs::remove_file(&self.filepath).expect("cannot delete pipe");
  }

  pub fn exists(&self) -> bool {
    self.filepath.exists()
  }

  pub fn open(&self) -> std::io::BufReader<std::fs::File> {
    let file = std::fs::File::open(&self.filepath).unwrap();
    std::io::BufReader::new(file)
  }
}

// constructs a fifo pipe in the current directory
pub fn in_dir(dirpath: &std::path::PathBuf) -> Pipe {
  Pipe {
    filepath: dirpath.join(".tertestrial.pipe"),
  }
}

pub fn listen(pipe: &Arc<Pipe>, sender: std::sync::mpsc::Sender<Signal>) {
  let pipe = Arc::clone(&pipe);
  std::thread::spawn(move || {
    loop {
      // TODO: don't create a new BufReader for each line
      for line in pipe.open().lines() {
        match line {
          Ok(text) => sender.send(Signal::Line(text)).unwrap(),
          Err(err) => {
            println!("error reading line: {}", err);
            sender.send(Signal::Exit).unwrap();
            break;
          }
        };
      }
    }
  });
}

use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum MyErr {
  UserErr { reason: String, guidance: String },
  DeveloperError(i64),
}

impl MyErr {
  fn new(reason: &str, guidance: &str) -> MyErr {
    MyErr::UserErr {
      reason: reason.to_string(),
      guidance: guidance.to_string(),
    }
  }
}

impl Error for MyErr {}

impl fmt::Display for MyErr {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      MyErr::UserErr { reason, guidance } => write!(f, "Error: {}\n{}", reason, guidance),
      MyErr::DeveloperError(code) => write!(f, "DEVELOPER ERR! {}", code),
    }
  }
}

#[test]
fn pipe_create() -> Result<(), MyErr> {
  let temp_path = tempfile::tempdir().unwrap().into_path();
  let pipe = in_dir(&temp_path);
  pipe.create();
  let mut created = vec![];
  let entries = std::fs::read_dir(&temp_path)
    .map_err(|err| MyErr::new("failed to read", "try a different one"))?;
  for entry in entries {
    created.push(
      entry
        .map_err(|err| MyErr::new("failed to read", "try a different one"))?
        .path(),
    );
  }

  let want = vec![pipe.filepath];
  assert_eq!(want, created);
  std::fs::remove_dir_all(&temp_path).map_err(|err| MyErr::new("x", "y"))?;
  Ok(())
}

#[test]
fn pipe_exists() {
  let temp_path = tempfile::tempdir().unwrap().into_path();
  let pipe = in_dir(&temp_path);
  assert!(!pipe.exists());
  pipe.create();
  assert!(pipe.exists());
  std::fs::remove_dir_all(&temp_path).unwrap();
}

#[test]
fn pipe_delete() {
  let temp_path = tempfile::tempdir().unwrap().into_path();
  let pipe = in_dir(&temp_path);
  pipe.create();
  assert!(pipe.exists());
  pipe.delete();
  assert!(!pipe.exists());
  std::fs::remove_dir_all(&temp_path).unwrap();
}
