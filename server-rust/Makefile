.SILENT:

build:  # builds the release binary
	cargo build --release

docs:  # shows the RustDoc in a browser
	cargo doc --open

help:   # shows all available Make commands
	cat Makefile | grep '^[^ ]*:' | grep -v '.PHONY' | grep -v '.SILENT' | grep -v help | sed 's/:.*#/#/' | column -s "#" -t

setup:  # prepare this workstation
	rustup target add x86_64-pc-windows-gnu
	rustup toolchain install stable-x86_64-pc-windows-gnu
	rustup target add x86_64-apple-darwin
	rustup toolchain install stable-x86_64-apple-darwin
	rustup target add aarch64-unknown-linux-gnu
	rustup toolchain install stable-aarch64-unknown-linux-gnu
	rustup target add aarch64-apple-darwin
	rustup toolchain install stable-aarch64-apple-darwin

test:  # runs all automated tests
	cargo clippy
	cargo test
