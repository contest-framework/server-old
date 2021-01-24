pub enum Signal {
  ReceivedLine(String),
  CannotReadPipe(std::io::Error),
  Exit,
}
