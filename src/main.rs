mod pipe;
mod sigint;
mod signal;

use std::env;
use std::io::prelude::*;
use std::sync::mpsc::channel;
use std::sync::Arc;

fn main() {
    // create the named pipe
    let pipe = Arc::new(pipe::in_dir(env::current_dir().unwrap()));
    pipe.create();

    // start the worker threads
    let (sender, receiver) = channel::<signal::Signal>();
    sigint::handle(sender.clone());
    listen_on_pipe(&pipe, sender);
    println!("Tertestrial is online");

    // process the signals from the worker threads
    for signal in receiver {
        match signal {
            signal::Signal::Line(line) => println!("received line: {}", line),
            signal::Signal::Finish => break,
        }
    }

    // cleanup
    pipe.delete()
}

fn listen_on_pipe(pipe: &Arc<pipe::Pipe>, sender: std::sync::mpsc::Sender<signal::Signal>) {
    let pipe = Arc::clone(&pipe);
    std::thread::spawn(move || {
        loop {
            // TODO: don't create a new BufReader for each line
            for line in pipe.open().lines() {
                match line {
                    Ok(text) => sender.send(signal::Signal::Line(text)).unwrap(),
                    Err(err) => {
                        println!("error reading line: {}", err);
                        sender.send(signal::Signal::Finish).unwrap();
                        break;
                    }
                };
            }
        }
    });
}

// // Patterns are sent from the client.
// struct Pattern {
//     filename: String,
// }

// // Actions are executed when receiving a pattern.
// struct Action {
//     pattern: Pattern,
//     command: String,
// }

// fn load_config() -> String {
//     let mut file = fs::File::open("tertestrial.yml").expect("Cannot open file");
//     let mut text = String::new();
//     file.read_to_string(&mut text).expect("Cannot read file");
//     let docs = YamlLoader::load_from_str(&text).unwrap();
// }
