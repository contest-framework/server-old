mod args;
mod channel;
mod config;
mod ctrl_c;
mod errors;
mod fifo;
mod run;
mod trigger;

use errors::UserErr;
use std::sync::Arc;

fn main() {
    match args::parse(std::env::args()) {
        args::Mode::Normal => normal(),
        args::Mode::Debug => debug(),
        args::Mode::Run(cmd) => run(cmd),
        args::Mode::Error(err) => print_user_error(err),
    }
}

fn normal() {
    let config = config::from_file();
    let (sender, receiver) = channel::create(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    match pipe.create() {
        fifo::CreateOutcome::AlreadyExists(path) => exit_pipe_exists(&path),
        fifo::CreateOutcome::OtherError(err) => panic!(err),
        fifo::CreateOutcome::Ok() => (),
    }
    fifo::listen(&pipe, sender);
    println!("Tertestrial is online, Ctrl-C to exit");
    for signal in receiver {
        match signal {
            channel::Signal::ReceivedLine(line) => match execute(line, &config) {
                Ok(_) => continue,
                Err(user_err) => {
                    print_user_error(user_err);
                    break;
                }
            },
            channel::Signal::CannotReadPipe(err) => {
                println!("Error: Cannot read from pipe: {}", err);
                break;
            }
            channel::Signal::Exit => {
                println!("\nSee you later!");
                break;
            }
        }
    }
    pipe.delete();
}

fn debug() {
    println!("debugging");
}

fn run(cmd: String) {
    println!("running cmd: {}", cmd);
}

fn execute(text: String, configuration: &config::Configuration) -> Result<(), UserErr> {
    let trigger = trigger::from_line(&text)?;
    let command = match configuration.get_command(trigger) {
        Some(command) => command,
        None => {
            return Err(UserErr::new(
                format!("cannot determine command for trigger \"{}\"", text),
                String::from(
                    "Please make sure that this trigger is listed in your configuration file",
                ),
            ))
        }
    };
    match run::run(command) {
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
