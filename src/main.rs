use nix::sys::stat;
use nix::unistd;
use std::env;
use std::fs;
use std::io::{prelude::*, BufReader};
use std::sync::mpsc::channel;
use std::thread;

const PIPE_FILENAME: &str = "foo.pipe";

#[derive(Debug)]
enum Signal {
    Line(String),
    Finish,
}

fn main() {
    let (sender, receiver) = channel::<Signal>();
    let ctrlc_sender = sender.clone();
    let line_sender = sender.clone();

    // spawn the SIGINT listener
    ctrlc::set_handler(move || {
        ctrlc_sender
            .send(Signal::Finish)
            .expect("cannot signal Finish");
    })
    .expect("cannot spawn SIGINT handler thread");

    // create the named pipe
    let current_dir = env::current_dir().expect("Cannot get current dir");
    let fifo_path = current_dir.join(PIPE_FILENAME);
    unistd::mkfifo(&fifo_path, stat::Mode::S_IRWXU).expect("cannot create pipe");

    // spawn the pipe reader thread
    thread::spawn(move || {
        println!("waiting for input ...");
        let pipe = fs::File::open(&fifo_path).expect("cannot open pipe");
        // read lines from the pipe
        loop {
            let reader = BufReader::new(&pipe);
            for line in reader.lines() {
                match line {
                    Ok(text) => line_sender
                        .send(Signal::Line(text))
                        .expect("cannot send line"),
                    Err(err) => {
                        println!("error reading line: {}", err);
                        break;
                    }
                };
            }
        }
    });

    loop {
        match receiver.recv().expect("error receiving") {
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
