// code to handle Ctrl-C

use super::signal::*;

// captures Ctrl-C and messages it as a Signal::Finish message via the given sender
pub fn handle(sender: std::sync::mpsc::Sender<Signal>) {
  ctrlc::set_handler(move || {
    sender.send(Signal::Finish).unwrap();
  })
  .unwrap();
}
