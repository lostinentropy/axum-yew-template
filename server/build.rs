use std::path::Path;

fn main() {
    // Switch working directory to project root
    std::env::set_current_dir(std::path::Path::new(".."))
        .expect("Failed to change working directory");

    // Warn user if frontend hasn't been build yet
    let path = Path::new("dist/");
    if !path.exists() {
        eprintln!("Path {path:?} not found. Have you run `trunk build`?");
        std::process::exit(1);
    }
}