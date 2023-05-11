set windows-shell := ["pwsh", "-NoLogo", "-Command"]

alias b := build
alias r := run

build:
    trunk build --release
    cargo build

run:
    trunk build --release
    cargo run

clean:
    trunk clean
    cargo clean