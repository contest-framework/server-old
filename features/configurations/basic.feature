Feature: configuring the commands

  As a developer using Tertestrial
  I want to be able to configure how my files are tested
  So that I can use Tertestrial with my own test tools.

  - Tertestrial is configured via a file "tertestrial.yml"
    in the root directory of the project
  - this file defines a number of actions:
    pairs of patterns that match data sent from the editor to templates of commands to run


  Background:
    Given Tertestrial runs with the configuration:
      """
      actions:
        - match:
            filename: '\.js$'
          command: 'echo Running Mocha with {{filename}}!'
        - match:
            filename: '\.js$'
            line: '\d+'
          command: 'echo Running Mocha with {{filename}}:{{line}}!'
      """


  Scenario: simple configuration file
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js!"
    When sending the command:
      """
      {"filename": "one.js", "line": 12}
      """
    Then I see "Running Mocha with one.js:12!"


  Scenario: no matching action
    When sending the command:
      """
      {"filename": "one.zonk"}
      """
      Then I see:
        """
        Error: no matching action found for {"filename":"one.zonk"}
        """
