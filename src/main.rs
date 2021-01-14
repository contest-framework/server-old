mod config;
mod ctrl_c;
mod fifo;
mod run;
mod signal;

use signal::*;
use std::sync::mpsc::channel;
use std::sync::Arc;

fn main() {
    // load the configuration
    let config = config::from_file();

    // set up the cross-thread communication infrastructure
    let (sender, receiver) = channel::<Signal>();

    // handle Ctrl-C
    ctrl_c::handle(sender.clone());

    // create the fifo pipe and listen on it
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    pipe.create();
    fifo::listen(&pipe, sender);

    // process the signals from the worker threads in an event loop
    println!("Tertestrial is online");
    for signal in receiver {
        match signal {
            Signal::Line(line) => run::run(line),
            Signal::Exit => break,
        }
    }

    // cleanup after Ctrl-C
    pipe.delete();
    println!("\nSee you later!");
}
