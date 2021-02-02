# Tertestrial configuration file syntax

The configuration file for Tertestrial has the name `.testconfig.json` and is in
JSON syntax. It has the following structure.

Options section:

- `beforeRun`: activities to do before running tests. Possible options are:
  - `clearScreen: true`: clears all content of the screen including scrollback.
    How well this works depends on your terminal application.
  - `emptyScreens: 1`: keeps the previous test in the scrollback behind the
    given number of empty screens
  - `newlines: <number>`: prints the given amount of newline characters
- `afterRun`: activities to do after running tests. Possible options are:
  - `newlines: <number>`: prints the given number of newline charactors
  - `indicatorLines: <number>`: prints the given number of lines indicating the
    test result
  - `indicatorBackground: <boolean>`: whether to indicate the test result via a
    change of the terminal background color
- `colors`: define colors
  - `indicatorLine`: colors for the test result indicator line
    - `pass: <bash color>`: when the test passes
    - `fail: <bash color>`: when the test fails
  - `indicatorBackground`: colors for the background
    - `pass: <bash color>`: when the test passes
    - `fail: <bash color>`: when the test fails
