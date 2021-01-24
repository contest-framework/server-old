mod config;
mod ctrl_c;
mod fifo;
mod run;
mod signal;
mod trigger;

use signal::*;
use std::sync::mpsc::channel;
use std::sync::Arc;

fn main() {
    let config = config::from_file();
    let (sender, receiver) = channel::<Signal>(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    // TODO: try creating the pipe and check for this error in the result
    if pipe.exists() {
        exit_pipe_exists(&pipe.filepath.display().to_string());
    }
    pipe.create();
    fifo::listen(&pipe, sender);
    println!("Tertestrial is online");
    for signal in receiver {
        match signal {
            Signal::Line(line) => run(line, &config),
            Signal::Exit => break,
        }
    }
    pipe.delete();
    println!("\nSee you later!");
}

fn run(text: String, configuration: &config::Configuration) {
    let trigger = trigger::from_line(text);
    match configuration.get_command(trigger) {
        Some(command) => run::run(command),
        None => println!("NONE"),
    }
}

fn exit_pipe_exists(path: &String) {
    println!("A fifo pipe \"{}\" already exists.", path);
    println!("This could mean a Tertestrial instance could already be running.");
    println!("If you are sure no other instance is running, please delete this file and start Tertestrial again.");
    std::process::exit(2);
}
