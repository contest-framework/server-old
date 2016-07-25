Feature: configuring the commands

  As a developer using Tertestrial
  I want to be able to configure how my files are tested
  So that I can use Tertestrial with my own test tools.

  - Tertestrial is configured via a file "tertestrial.config"
    in the root directory of the project
  - this file defines a number of mappers:
    Bash functions that print the command to run for different situations
  - multiple configurations can be stored in files "tertestrial-1.config",
    "tertestrial-2.config", etc


  Scenario: simple configuration file
    Given a file "tertestrial.ls" with the content:
      """
      mappings:
        js:
          test-file: ({filename}) -> "echo Running Mocha with #{filename}!"
          test-line: ({filename, line}) -> "echo Running Mocha with #{filename}:#{line}!"
      """
    And starting tertestrial
    When sending the command:
      | OPERATION | FILENAME |
      | testFile  | one.js   |
    Then I see "Running Mocha with one.js!"
    When sending the command:
      | OPERATION | FILENAME | LINE |
      | testLine  | one.js   | 12   |
    Then I see "Running Mocha with one.js:12!"


  Scenario: configuration file missing
    When starting tertestrial
    Then I see "Error: cannot find configuration file"


  Scenario: mapping missing
    Given a file "tertestrial.ls" with the content:
      """
      mappings:
        js:
          test-file: ({filename}) -> "echo Running Mocha with #{filename}!"
      """
    And starting tertestrial
    When sending the command:
      | OPERATION | FILENAME |
      | testFile  | one.zonk |
    Then I see "Error: no mapping for file type zonk"


  Scenario: mapper for operation missing
    Given a file "tertestrial.ls" with the content:
      """
      mappings:
        js:
          test: ({filename}) -> "echo Running Mocha with #{filename}!"
      """
    And starting tertestrial
    When sending the command:
      | OPERATION | FILENAME |
      | zonk      | one.js   |
    Then I see "Error: no mapper for operation zonk on file type js"

