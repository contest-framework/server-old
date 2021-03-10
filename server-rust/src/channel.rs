//! cross-thread communication via a message channel

use std::sync::mpsc;

pub type Sender = mpsc::Sender<Signal>;

/// Signals that can be sent over the channel.
pub enum Signal {
    /// A command was received from the FIFO
    ReceivedLine(String),
    /// Error reading the FIFO
    CannotReadPipe(std::io::Error),
    /// Received Ctrl-C
    Exit,
}

pub fn create() -> (mpsc::Sender<Signal>, mpsc::Receiver<Signal>) {
    mpsc::channel::<Signal>()
}
