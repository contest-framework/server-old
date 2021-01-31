#[macro_use]
extern crate prettytable;

use errors::UserErr;
use std::sync::Arc;

mod args;
mod channel;
mod config;
mod ctrl_c;
mod errors;
mod fifo;
mod run;
mod trigger;

fn main() {
    match args::parse(std::env::args()) {
        Ok(cmd) => match cmd {
            args::Command::Normal => normal(false),
            args::Command::Debug => normal(true),
            args::Command::Run(cmd) => run(cmd),
            args::Command::Setup => setup(),
            args::Command::Version => version(),
        },
        Err(e) => print_user_error(e),
    }
}

fn normal(debug: bool) {
    let config = config::from_file();
    if debug {
        println!("using this configuration:");
        println!("{}", config);
    }
    let (sender, receiver) = channel::create(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = Arc::new(fifo::in_dir(&std::env::current_dir().unwrap()));
    match pipe.create() {
        fifo::CreateOutcome::AlreadyExists(path) => exit_pipe_exists(&path),
        fifo::CreateOutcome::OtherError(err) => panic!(err),
        fifo::CreateOutcome::Ok() => (),
    }
    fifo::listen(&pipe, sender);
    match debug {
        false => println!("Tertestrial is online, Ctrl-C to exit"),
        true => println!("Tertestrial is online in debug mode, Ctrl-C to exit"),
    }
    for signal in receiver {
        match signal {
            channel::Signal::ReceivedLine(line) => match debug {
                false => match execute(line, &config) {
                    Ok(_) => continue,
                    Err(user_err) => {
                        print_user_error(user_err);
                        break;
                    }
                },
                true => println!("received from client: {}", line),
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

fn run(cmd: String) {
    println!("running cmd: {}", cmd);
    let config = config::from_file();
    match execute(cmd, &config) {
        Ok(_) => {}
        Err(user_err) => print_user_error(user_err),
    }
}

fn setup() {
    match config::create() {
        Ok(_) => println!("Created configuration file "),
        Err(e) => println!("Cannot create file: {}", e),
    }
}

fn version() {
    println!("Tertestrial v0.4.0-alpha");
}

fn execute(text: String, configuration: &config::Configuration) -> Result<(), UserErr> {
    let trigger = trigger::from_line(&text)?;
    let command = match configuration.get_command(trigger) {
        Some(command) => command,
        None => {
            return Err(UserErr::new(
                format!(r#"cannot determine command for trigger "{}""#, text),
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
            format!("test command not found: {}", command),
            format!(
                "I received this trigger from the client: {}\
                Your config file specifies to run this command in that case: {}\
                I couldn't run this command. Please verify that the command is in the path or fix your config file.",
                text, command
            ),
        )),
    }
}

fn exit_pipe_exists(path: &str) {
    println!(r#"A fifo pipe "{}" already exists."#, path);
    println!("This could mean a Tertestrial instance could already be running.");
    println!("If you are sure no other instance is running, please delete this file and start Tertestrial again.");
    std::process::exit(2);
}

fn print_user_error(err: UserErr) {
    println!("\nUser error: {}\n\n{}", err.reason, err.guidance);
}
