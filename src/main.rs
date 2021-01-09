use nix::sys::stat;
use nix::unistd;
use std::env;
use std::fs;
use std::io::{prelude::*, BufReader};
use std::sync::mpsc::channel;
use std::thread;

const PIPE_FILENAME: &str = "foo.pipe";

enum Signal {
    Line(String),
    Finish,
}

fn main() {
    let (sender, receiver) = channel::<Signal>();

    // create the named pipe
    let current_dir = env::current_dir().unwrap();
    let fifo_path = current_dir.join(PIPE_FILENAME);
    unistd::mkfifo(&fifo_path, stat::Mode::S_IRWXU).expect("cannot create pipe");

    // start the SIGINT listener thread
    let ctrlc_sender = sender.clone();
    ctrlc::set_handler(move || {
        ctrlc_sender.send(Signal::Finish).unwrap();
    })
    .unwrap();

    // start the pipe reader thread
    let line_sender = sender.clone();
    thread::spawn(move || {
        let pipe = fs::File::open(&fifo_path).unwrap();
        loop {
            // TODO: don't create a new BufReader for each line
            let reader = BufReader::new(&pipe);
            for line in reader.lines() {
                match line {
                    Ok(text) => line_sender.send(Signal::Line(text)).unwrap(),
                    Err(err) => {
                        println!("error reading line: {}", err);
                        line_sender.send(Signal::Finish).unwrap();
                        break;
                    }
                };
            }
        }
    });

    // process the signals from the worker threads
    loop {
        match receiver.recv().unwrap() {
            Signal::Line(line) => println!("received line: {}", line),
            Signal::Finish => break,
        }
    }

    // delete the named pipe
    let fifo_path = current_dir.join(PIPE_FILENAME);
    fs::remove_file(fifo_path).expect("cannot delete pipe");
    println!("\nThanks for using Tertestrial!")
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
