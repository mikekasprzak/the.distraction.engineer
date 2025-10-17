+++
title = "Rust Setup"
+++
## Installation


```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Updating Rust Version
```bash
rustup update
```

## Hello World
<https://rust-lang.org/learn/get-started/>

```bash
cargo new hello

# hello/
#   .gitignore
#   Cargo.toml
#   src/
#     main.rs
```

#### Cargo.toml
```toml
[package]
name = "hello"
version = "0.1.0"
edition = "2024"

[dependencies]
```

#### main.rs
```rust
fn main() {
    println!("Hello, world!");
}
```

### Build and run
```bash
cargo build
#    Compiling hello v0.1.0 (/home/mike/Work/science/hello)
#     Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.68s

cargo run
#    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.03s
#     Running `target/debug/hello`
# Hello, world!

./target/debug/hello
# Hello, world!

cargo build -r
cargo build --release
#    Compiling hello v0.1.0 (/home/mike/Work/science/hello)
#     Finished `release` profile [optimized] target(s) in 0.16s

cargo run -r
cargo run --release
#    Finished `release` profile [optimized] target(s) in 0.01s
#     Running `target/release/hello`
# Hello, world!

./target/release/hello
# Hello, world!

find . -name 'hello' -print0 | xargs -0 ls -lhS
# 3.8M ./target/debug/hello
# 439K ./target/release/hello
```

### Generating a smaller binary
#### Cargo.toml
```toml
[package]
name = "hello"
version = "0.1.0"
edition = "2024"

[dependencies]

[profile.release]
opt-level = "z"    # Optimize for size
strip = true       # Strip symbols
lto = true         # Link-time optimizations

codegen-units = 1  # Certain optimizations only work if parallel code generation is disabled
panic = "abort"    # Don't generate helpful backtraces on panic!()
```

More here: <https://github.com/johnthagen/min-sized-rust>

## Using Crates
<https://crates.io/crates/ferris-says>

Via Cargo (no need to lookup version number):

```bash
cargo add ferris-says
#    Updating crates.io index
#      Adding ferris-says v0.3.2 to dependencies
#             Features:
#             - clippy
#    Updating crates.io index
#     Locking 12 packages to latest Rust 1.90.0 compatible versions
#      Adding aho-corasick v1.1.3
#      Adding ferris-says v0.3.2
#      Adding memchr v2.7.6
#      Adding regex v1.12.2
#      Adding regex-automata v0.4.13
#      Adding regex-syntax v0.8.8
#      Adding smallvec v1.15.1
#      Adding smawk v0.3.2
#      Adding textwrap v0.16.2
#      Adding unicode-linebreak v0.1.5
#      Adding unicode-width v0.1.14
#      Adding unicode-width v0.2.2

cargo update ferris-says
#    Updating crates.io index
#     Locking 0 packages to latest Rust 1.90.0 compatible versions
```

Or by editing `Cargo.toml`:

#### Cargo.toml
```toml
[package]
name = "hello"
version = "0.1.0"
edition = "2024"

[dependencies]
ferris-says = "0.3.2"
```

## Cargo.toml
### [dependencies] section
<https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html>

> Versions are considered compatible if their left-most non-zero major/minor/patch component is the same. This is different from SemVer which considers all pre-1.0.0 packages to be incompatible.

```toml
# Lets say latest version is 0.3.2
ferris-says = "0.3.2"  # 0.3.2
ferris-says = "0.3.1"  # 0.3.2
ferris-says = "^0.3.1" # 0.3.2
ferris-says = "0.3"    # 0.3.2
ferris-says = "0"      # 0.3.2

# https://crates.io/crates/ftml
# Lets say latest version is 1.36.1
ftml = "1.36.1"        # 1.36.1
ftml = "1.36"          # 1.36.1
ftml = "1"             # 1.36.1
ftml = "1.12.3"        # 1.36.1
ftml = "0"             # 0.10.2
ftml = "0.5"           # 0.5.0
ftml = "~1.12.3"       # 1.12.6
ftml = "~1.12"         # 1.12.6
ftml = "~1"            # 1.36.1
ftml = "~1.22.1"       # 1.22.2
ftml = "= 1.22.1"      # 1.22.1
ftml = "0.*"           # 0.10.2
ftml = "*"             # crates.io error

# Specified via a Git repository
regex = { git = "https://github.com/rust-lang/regex.git" }
regex-lite   = { git = "https://github.com/rust-lang/regex.git" }
regex-syntax = { git = "https://github.com/rust-lang/regex.git" }

# Specified via path (after running `cargo new hello_utils`)
hello_utils = { path = "hello_utils" }

# Paths must be exact, unlike git that will search the repo for a matching `Cargo.toml` file
regex-lite   = { path = "../regex/regex-lite" }
regex-syntax = { path = "../regex/regex-syntax" }

# path or git will be used when built locally.
# When THIS crate is published to crates.io, the matching version will be used instead
bitflags = { path = "my-bitflags", version = "1.0" }
smallvec = { git = "https://github.com/servo/rust-smallvec.git", version = "1.0" }

# Platform or architecture specific dependencies
[target.'cfg(windows)'.dependencies]
winhttp = "0.4.0"

[target.'cfg(unix)'.dependencies]
openssl = "1.0.1"

[target.'cfg(target_arch = "x86")'.dependencies]
native-i686 = { path = "native/i686" }

[target.'cfg(target_arch = "x86_64")'.dependencies]
native-x86_64 = { path = "native/x86_64" }
```

### [features] section
<https://doc.rust-lang.org/cargo/reference/features.html>

> Cargo “features” provide a mechanism to express conditional compilation and optional dependencies. A package defines a set of named features in the [features] table of Cargo.toml, and each feature can either be enabled or disabled.

#### Cargo.toml
```toml
[features]
default = ["png", "webp"]  # What features to enable by default
bmp = []
png = []
ico = ["bmp", "png"]       # ico requires the bmp and png features
webp = []                  # webp does not enable any other features
```

```bash
cargo build --features bmp
# builds with default and all specified features
```

#### lib.rs
```rust
#[cfg(feature = "webp")]
pub mod webp;

#[cfg(feature = "webp")]
pub fn function_that_uses_webp_module() {
    // ...
}
```

### Optional Dependencies
#### Cargo.toml
```toml
[dependencies]
gif = { version = "0.11.1", optional = true }

# The above implies this
[features]
gif = ["dep:gif"]
```

```bash
cargo build --features gif
```

## Modules (Libraries)
```bash
cargo new mylib --lib
#    Creating library `mylib` package

# mylib/
#   Cargo.toml
#   src/
#     lib.rs
```

#### Cargo.toml
```toml
[package]
name = "mylib"
version = "0.1.0"
edition = "2024"

[dependencies]
```

#### lib.rs
```rust
pub fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```

NOTE: Because libraries aren't run directly, the template creates a test

```bash
cargo test
#    Compiling mylib v0.1.0 (/home/mike/Work/science/hello/mylib)
#     Finished `test` profile [unoptimized + debuginfo] target(s) in 0.37s
#      Running unittests src/lib.rs (target/debug/deps/mylib-adba83cfc6455e3f)
#
# running 1 test
# test tests::it_works ... ok
#
# test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
#
#    Doc-tests mylib
#
# running 0 tests
#
# test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```
