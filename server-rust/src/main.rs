#[macro_use]
extern crate prettytable;

use errors::UserErr;

mod args;
mod channel;
mod config;
mod ctrl_c;
mod errors;
mod fifo;
mod run;
mod trigger;

fn main() {
    let panic_result = std::panic::catch_unwind(|| {
        if let Err(user_err) = main_with_err() {
            println!("\nError: {}\n\n{}", user_err.reason, user_err.guidance);
        }
    });
    let _ = fifo::in_dir(&std::env::current_dir().unwrap()).delete();
    if panic_result.is_err() {
        panic!(panic_result);
    }
}

fn main_with_err() -> Result<(), UserErr> {
    match args::parse(std::env::args())? {
        args::Command::Normal => listen(false),
        args::Command::Debug => listen(true),
        args::Command::Run(cmd) => {
            println!("running cmd: {}", cmd);
            let config = config::from_file()?;
            run_command(cmd, &config)
        }
        args::Command::Setup => config::create(),
        args::Command::Version => {
            println!("Tertestrial v0.4.0-alpha");
            Ok(())
        }
    }
}

fn listen(debug: bool) -> Result<(), UserErr> {
    let config = config::from_file()?;
    if debug {
        println!("using this configuration:");
        println!("{}", config);
    }
    let (sender, receiver) = channel::create(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = fifo::in_dir(&std::env::current_dir().unwrap());
    match pipe.create() {
        fifo::CreateOutcome::AlreadyExists(path) => return Err(UserErr::new(format!("A fifo pipe \"{}\" already exists.", path), "This could mean a Tertestrial instance could already be running.\nIf you are sure no other instance is running, please delete this file and start Tertestrial again.")),
        fifo::CreateOutcome::OtherError(err) => panic!(err),
        fifo::CreateOutcome::Ok() => {}
    }
    fifo::listen(pipe, sender);
    match debug {
        false => println!("Tertestrial is online, Ctrl-C to exit"),
        true => println!("Tertestrial is online in debug mode, Ctrl-C to exit"),
    }
    let mut result: Result<(), UserErr> = Ok(());
    for signal in receiver {
        match signal {
            channel::Signal::ReceivedLine(line) => match debug {
                true => println!("received from client: {}", line),
                false => {
                    result = run_command(line, &config);
                    if result.is_err() {
                        break;
                    }
                }
            },
            channel::Signal::CannotReadPipe(err) => {
                result = Err(UserErr::new(
                    format!("Cannot read from pipe: {}", err),
                    "This is an internal error",
                ));
                break;
            }
            channel::Signal::Exit => {
                println!("\nSee you later!");
                break;
            }
        }
    }
    result
}

fn run_command(text: String, configuration: &config::Configuration) -> Result<(), UserErr> {
    let trigger = trigger::from_string(&text)?;
    if configuration.options.before_run.clear_screen {
        print!("{esc}[2J{esc}[1;1H", esc = 27 as char);
    }
    let command = configuration.get_command(trigger)?;
    match run::run(&command) {
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
            &format!(
                "I received this trigger from the client: {}\
                Your config file specifies to run this command in that case: {}\
                I couldn't run this command. Please verify that the command is in the path or fix your config file.",
                text, command
            ),
        )),
    }
}
