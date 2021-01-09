mod pipe;
mod sigint;
mod signal;

use signal::*;
use std::env;
use std::sync::mpsc::channel;
use std::sync::Arc;

fn main() {
    // set up the cross-thread communication infrastructure
    let (sender, receiver) = channel::<Signal>();

    // handle Ctrl-C
    sigint::handle(sender.clone());

    // create the named pipe and listen on it
    let pipe = Arc::new(pipe::in_dir(env::current_dir().unwrap()));
    pipe.create();
    pipe::listen(&pipe, sender);

    // process the signals from the worker threads
    println!("Tertestrial is online");
    for signal in receiver {
        match signal {
            Signal::Line(line) => println!("received line: {}", line),
            Signal::Finish => break,
        }
    }

    // cleanup
    pipe.delete();
    println!("\nSee you later!");
}
