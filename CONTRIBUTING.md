# Tertestrial Server Developer Documentation

- you need Rust 2018 stable: https://www.rust-lang.org/tools/install
- run tests: `cargo test`
- see the [Makefile](Makefile) for avalailable Make commands

## Create your own editor plugin

Editor plugins write (append) the following JSON string into the existing file
`.tertestrial.tmp`:

In addition to your [application-specific commands](#custom-configurations),
your editor plugin needs to support these built-in infrastructure messages:

- switching to a different [action set](#multiple-action-sets):

  - by index (1 based)

    ```json
    { "actionSet": 2 }
    ```

  - by name

    ```json
    { "actionSet": "headless" }
    ```

  - cycle through action sets

    ```json
    { "cycleActionSet": "next" }
    ```

- re-run the last test:

  ```json
  { "repeatLastTest": true }
  ```

Ideally your editor plugin should also implement "auto-test". A mode the user
can toggle on and off, which triggers a re-run of the last test when any file is
saved.
