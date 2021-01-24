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

fn main() {
    let config = config::from_file();
    let (sender, receiver) = channel::<Signal>(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    match pipe.create() {
        fifo::CreateOutcome::Ok() => {}
        fifo::CreateOutcome::AlreadyExists(path) => exit_pipe_exists(&path),
        fifo::CreateOutcome::OtherError(err) => panic!(err),
    }
    fifo::listen(&pipe, sender);
    println!("Tertestrial is online, Ctrl-C to exit");
    for signal in receiver {
        match signal {
            Signal::ReceivedLine(line) => match run(line, &config) {
                Ok(_) => continue,
                Err(user_err) => {
                    print_user_error(user_err);
                    break;
                }
            },
            Signal::CannotReadPipe(err) => {
                println!("cannot reading line from pipe: {}", err);
                break;
            }
            Signal::Exit => {
                println!("\nSee you later!");
                break;
            }
        }
    }
    pipe.delete();
}

fn run(text: String, configuration: &config::Configuration) -> Result<(), UserErr> {
    let trigger = trigger::from_line(&text)?;
    match configuration.get_command(trigger) {
        None => Err(UserErr::new(
            format!("cannot determine command for trigger \"{}\"", text),
            String::from("Please make sure that this trigger is listed in your configuration file"),
        )),
        Some(command) => match run::run(command) {
            run::Outcome::TestPass() => {
                println!("SUCCESS!");
                Ok(())
            }
            run::Outcome::TestFail() => {
                println!("FAILED!");
                Ok(())
            }
            run::Outcome::NotFound(command) => Err(UserErr::new(
                String::from(format!("test command not found: {}", command)),
                String::from(format!(
                    "I received this trigger from the client: {}\nYour config file specifies to run this command in that case: {}\nI couldn't run this command. Please verify that the command is in the path or fix your config file.",
                    text,
                    command)
                ),
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

fn print_user_error(err: UserErr) {
    println!("\nUser error: {}\n\n{}", err.reason, err.guidance);
}
