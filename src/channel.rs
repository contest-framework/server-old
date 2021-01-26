// provides cross-thread communication via a message channel

use std::sync::mpsc;

pub type Sender = mpsc::Sender<Signal>;
// pub type Receiver = mpsc::Receiver<Signal>;

// signals that can be sent over the channel
pub enum Signal {
  ReceivedLine(String),
  CannotReadPipe(std::io::Error),
  Exit,
}

pub fn create() -> (mpsc::Sender<Signal>, mpsc::Receiver<Signal>) {
  mpsc::channel::<Signal>()
}
