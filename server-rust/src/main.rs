#[macro_use]
extern crate prettytable;

use errors::TertError;
use std::io::Write;
use termcolor::WriteColor;
use terminal_size::terminal_size;

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
        if let Err(tert_error) = main_with_err() {
            let (msg, guidance) = tert_error.messages();
            println!("\nError: {}\n\n{}", msg, guidance);
        }
    });
    let _ = fifo::in_dir(&std::env::current_dir().unwrap()).delete();
    if panic_result.is_err() {
        panic!(panic_result);
    }
}

fn main_with_err() -> Result<(), TertError> {
    match args::parse(std::env::args())? {
        args::Command::Normal => listen(false),
        args::Command::Debug => listen(true),
        args::Command::Run(cmd) => {
            println!("running cmd: {}", cmd);
            let config = config::from_file()?;
            run_with_decoration(cmd, &config)
        }
        args::Command::Setup => config::create(),
        args::Command::Version => {
            println!("Tertestrial v0.4.0-alpha");
            Ok(())
        }
    }
}

fn listen(debug: bool) -> Result<(), TertError> {
    let config = config::from_file()?;
    if debug {
        println!("using this configuration:");
        println!("{}", config);
    }
    let (sender, receiver) = channel::create(); // cross-thread communication channel
    ctrl_c::handle(sender.clone());
    let pipe = fifo::in_dir(&std::env::current_dir().unwrap());
    match pipe.create() {
        fifo::CreateOutcome::AlreadyExists(path) => {
            return Err(TertError::FifoAlreadyExists { path })
        }
        fifo::CreateOutcome::OtherError(err) => panic!(err),
        fifo::CreateOutcome::Ok() => {}
    }
    fifo::listen(pipe, sender);
    match debug {
        false => println!("Tertestrial is online, Ctrl-C to exit"),
        true => println!("Tertestrial is online in debug mode, Ctrl-C to exit"),
    }
    for signal in receiver {
        match signal {
            channel::Signal::ReceivedLine(line) => match debug {
                true => println!("received from client: {}", line),
                false => run_with_decoration(line, &config)?,
            },
            channel::Signal::CannotReadPipe(err) => {
                return Err(TertError::FifoCannotRead {
                    err: err.to_string(),
                })
            }
            channel::Signal::Exit => {
                println!("\nSee you later!");
                return Ok(());
            }
        }
    }
    Ok(())
}

fn run_with_decoration(text: String, config: &config::Configuration) -> Result<(), TertError> {
    for _ in 0..config.options.before_run.newlines {
        println!();
    }
    if config.options.before_run.clear_screen {
        print!("{esc}[2J{esc}[1;1H", esc = 27 as char);
    }
    let result = run_command(text, config)?;
    for _ in 0..config.options.after_run.newlines {
        println!();
    }
    match terminal_size() {
        None => println!("Warning: cannot determine terminal size"),
        Some((width, _)) => {
            for _ in 0..config.options.after_run.indicator_lines {
                let mut stdout = termcolor::StandardStream::stdout(termcolor::ColorChoice::Auto);
                let color = if result {
                    termcolor::Color::Green
                } else {
                    termcolor::Color::Red
                };
                stdout
                    .set_color(termcolor::ColorSpec::new().set_fg(Some(color)))
                    .unwrap();
                let text: String = std::iter::repeat("█").take(width.0 as usize).collect();
                writeln!(&mut stdout, "{}", text).unwrap();
            }
        }
    }
    Ok(())
}

fn run_command(text: String, configuration: &config::Configuration) -> Result<bool, TertError> {
    let trigger = trigger::from_string(&text)?;
    let command = configuration.get_command(trigger)?;
    match run::run(&command) {
        run::Outcome::TestPass() => {
            println!("SUCCESS!");
            Ok(true)
        }
        run::Outcome::TestFail() => {
            println!("FAILED!");
            Ok(false)
        }
        run::Outcome::NotFound(command) => Err(TertError::RunCommandNotFound { command }),
    }
}
