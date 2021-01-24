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

  pub fn path_str(&self) -> String {
    self.filepath.display().to_string()
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

#[test]
fn pipe_create() -> Result<(), std::io::Error> {
  let temp_path = tempfile::tempdir().unwrap().into_path();
  let pipe = in_dir(&temp_path);
  pipe.create();
  let mut created = vec![];
  for file in std::fs::read_dir(&temp_path)? {
    created.push(file?.path());
  }
  let want = vec![pipe.filepath];
  assert_eq!(want, created);
  std::fs::remove_dir_all(&temp_path)?;
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
