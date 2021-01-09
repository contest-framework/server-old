mod pipe;

use std::env;
use std::io::prelude::*;
use std::sync::mpsc::channel;
use std::sync::Arc;

enum Signal {
    Line(String),
    Finish,
}

fn main() {
    // create the named pipe
    let pipe = Arc::new(pipe::Pipe::in_dir(env::current_dir().unwrap()));
    pipe.create();

    // start the worker threads
    let (sender, receiver) = channel::<Signal>();
    handle_sigint(sender.clone());
    listen_on_pipe(&pipe, sender);
    println!("Tertestrial is ready");

    // process the signals from the worker threads
    for signal in receiver {
        match signal {
            Signal::Line(line) => println!("received line: {}", line),
            Signal::Finish => break,
        }
    }

    // cleanup
    pipe.delete()
}

// captures Ctrl-C and messages it as a Signal::Finish message via the given sender
fn handle_sigint(sender: std::sync::mpsc::Sender<Signal>) {
    let ctrlc_sender = sender.clone();
    ctrlc::set_handler(move || {
        ctrlc_sender.send(Signal::Finish).unwrap();
    })
    .unwrap();
}

fn listen_on_pipe(pipe: &Arc<pipe::Pipe>, sender: std::sync::mpsc::Sender<Signal>) {
    let pipe = Arc::clone(&pipe);
    std::thread::spawn(move || {
        loop {
            // TODO: don't create a new BufReader for each line
            for line in pipe.open().lines() {
                match line {
                    Ok(text) => sender.send(Signal::Line(text)).unwrap(),
                    Err(err) => {
                        println!("error reading line: {}", err);
                        sender.send(Signal::Finish).unwrap();
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
