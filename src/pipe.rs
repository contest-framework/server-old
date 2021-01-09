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
