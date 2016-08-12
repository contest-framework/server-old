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
          command: 'echo Running all tests'

        - match:
            filename: '\.js$'
          command: 'echo Running Mocha with {{filename}}'

        - match:
            filename: '\.js$'
            line: '\d+'
          command: 'echo Running Mocha with {{filename}}:{{line}}'
      """


  Scenario: sending a command with zero match keys
    When sending the command:
      """
      {}
      """
    Then I see "Running all tests"
    And the process is still running


  Scenario: sending a command with one match key
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js"
    And the process is still running


  Scenario: sending a command with two match keys
    When sending the command:
      """
      {"filename": "one.js", "line": 12}
      """
    Then I see "Running Mocha with one.js:12"
    And the process is still running


  Scenario: no matching action
    When sending the command:
      """
      {"filename": "one.zonk"}
      """
    Then I see:
      """
      Error: no matching action found for {"filename":"one.zonk"}
      """
    And the process is still running
