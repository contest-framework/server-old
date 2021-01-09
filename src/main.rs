use nix::sys::stat;
use nix::unistd;
use std::env;
use std::fs;
use std::io::{prelude::*, BufReader};
use std::sync::mpsc::channel;
use std::thread;
use std::time::Duration;

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
    thread::spawn(move || {
        println!("SIGINT thread sleeping for 2 seconds ...");
        thread::sleep(Duration::from_secs(5));
        println!("SIGINT thread resuming");
        ctrlc_sender.send(Signal::Finish).unwrap();
    });

    // create new named pipe
    let current_dir = env::current_dir().expect("Cannot get current dir");
    let fifo_path = current_dir.join("foo.pipe");
    unistd::mkfifo(&fifo_path, stat::Mode::S_IRWXU).expect("cannot create pipe");

    // spawn the pipe reader thread
    println!("waiting for input ...");
    thread::spawn(move || {
        let pipe = fs::File::open(&fifo_path).expect("cannot open pipe");
        // read line by line from the pipe
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

    println!("starting the listener loop");
    loop {
        println!("listening for signals ...");
        let signal = receiver.recv().expect("error receiving");
        println!("received signal: {:?}", signal);
        match signal {
            Signal::Line(text) => println!("received line: {}", text),
            Signal::Finish => {
                println!("received SIGINT");
                break;
            }
        }
    }

    // delete the named pipe
    let fifo_path = current_dir.join("foo.pipe");
    fs::remove_file(fifo_path).expect("cannot delete pipe")
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

// fn main() -> io::Result<()> {
//     unsafe { libc::mkfifo(cstr.as_ptr(), mode.bits() as mode_t) }
//     let file = File::open("")?;
//     let reader = BufReader::new(file);

//     for line in reader.lines() {
//         println!("{}", line?);
//     }

//     Ok(())
// }

// fn main() {
//     let contents = fs::read_(filename).expect("Something went wrong reading the file");

//     // println!("Guess the number!");
//     // let secret_number = rand::thread_rng().gen_range(1, 101);
//     // loop {
//     //     println!("Please input your guess.");
//     //     let mut guess = String::new();
//     //     io::stdin()
//     //         .read_line(&mut guess)
//     //         .expect("Failed to read line");
//     //     let guess: u32 = match guess.trim().parse() {
//     //         Ok(num) => num,
//     //         Err(_) => continue,
//     //     };
//     //     println!("You guessed: {}", guess);
//     //     match guess.cmp(&secret_number) {
//     //         Ordering::Less => println!("Too small!"),
//     //         Ordering::Greater => println!("Too big!"),
//     //         Ordering::Equal => {
//     //             println!("You win!");
//     //             break;
//     //         }
//     //     }
//     // }
// }

// fn load_config() -> String {
//     let mut file = fs::File::open("tertestrial.yml").expect("Cannot open file");
//     let mut text = String::new();
//     file.read_to_string(&mut text).expect("Cannot read file");
//     let docs = YamlLoader::load_from_str(&text).unwrap();
// }
