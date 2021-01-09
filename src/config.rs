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
