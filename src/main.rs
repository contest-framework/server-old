mod config;
mod ctrl_c;
mod errors;
mod fifo;
mod run;
mod signal;
mod trigger;

use errors::UserErr;
use signal::*;
use std::sync::mpsc::channel;
use std::sync::Arc;

fn main() -> Result<(), UserErr> {
    let config = config::from_file();
    let (sender, receiver) = channel::<Signal>(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    // TODO: don't do the extra check, try creating the pipe
    // and check for this error in the result
    if pipe.exists() {
        exit_pipe_exists(&pipe.path_str());
    }
    pipe.create();
    fifo::listen(&pipe, sender);
    println!("Tertestrial is online");
    for signal in receiver {
        match signal {
            Signal::Line(line) => run(line, &config)?,
            Signal::Exit => break,
        }
    }
    pipe.delete();
    println!("\nSee you later!");
    Ok(())
}

fn run(text: String, configuration: &config::Configuration) -> Result<(), UserErr> {
    let trigger = trigger::from_line(&text)?;
    match configuration.get_command(trigger) {
        None => Err(UserErr::new(
            format!("cannot determine command for trigger \"{}\"", text),
            String::from("Please make sure that this trigger is listed in your configuration file"),
        )),
        Some(command) => match run::run(command) {
            run::Outcome::TestPass => {
                println!("SUCCESS!");
                Ok(())
            }
            run::Outcome::TestFail => {
                println!("FAILED!");
                Ok(())
            }
            run::Outcome::NotFound => Err(UserErr::new(
                String::from("test command not found"),
                String::from("the command was not found"),
            )),
        },
    }
}

fn exit_pipe_exists(path: &String) {
    println!("A fifo pipe \"{}\" already exists.", path);
    println!("This could mean a Tertestrial instance could already be running.");
    println!("If you are sure no other instance is running, please delete this file and start Tertestrial again.");
    std::process::exit(2);
}
