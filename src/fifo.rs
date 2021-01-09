// This file contains code to manage the FIFO pipe and read from it.

use super::signal;
use std::io::prelude::*;

use std::sync::Arc;

// A fifo pipe
pub struct Pipe {
  filepath: std::path::PathBuf,
}

impl Pipe {
  pub fn create(&self) {
    nix::unistd::mkfifo(&self.filepath, nix::sys::stat::Mode::S_IRWXU).expect("cannot create pipe");
  }

  pub fn delete(&self) {
    std::fs::remove_file(&self.filepath).expect("cannot delete pipe");
  }

  pub fn open(&self) -> std::io::BufReader<std::fs::File> {
    let file = std::fs::File::open(&self.filepath).unwrap();
    std::io::BufReader::new(file)
  }
}

// constructs a fifo pipe in the current directory
pub fn in_dir(dirpath: std::path::PathBuf) -> Pipe {
  Pipe {
    filepath: dirpath.join("foo.pipe"),
  }
}

pub fn listen(pipe: &Arc<Pipe>, sender: std::sync::mpsc::Sender<signal::Signal>) {
  let pipe = Arc::clone(&pipe);
  std::thread::spawn(move || {
    loop {
      // TODO: don't create a new BufReader for each line
      for line in pipe.open().lines() {
        match line {
          Ok(text) => sender.send(signal::Signal::Line(text)).unwrap(),
          Err(err) => {
            println!("error reading line: {}", err);
            sender.send(signal::Signal::Exit).unwrap();
            break;
          }
        };
      }
    }
  });
}
