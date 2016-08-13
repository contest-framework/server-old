Feature: flexible configuration file languages

  As a developer using Tertestrial
  I want to be able to create the configuration file in the language of my choice
  So that I can use Tertestrial even if I don't understand YML.

  - the configuration file can be written in any language
    that compiles to JS


  Scenario: JSON config file
    Given Tertestrial runs with the configuration file "tertestrial.json":
      """
      {
        "actions": [
          {
            "match": {
              "filename": ".js$"
            },
            "command": "echo Running Mocha with {{filename}}"
          }
        ]
      }
      """
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js"
    And the process is still running


  Scenario: JS config file
    Given Tertestrial runs with the configuration file "tertestrial.js":
      """
      module.exports = {
        actions: [
          {
            match: {
              filename: ".js$"
            },
            command: "echo Running Mocha with {{filename}}"
          }
        ]
      }
      """
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js"
    And the process is still running


  Scenario: LiveScript config file
    Given Tertestrial runs with the configuration file "tertestrial.ls":
      """
      module.exports =
        actions:

          * match:
              filename: '\.js$'
            command: "echo Running Mocha with {{filename}}"

          * match:
              filename: '\.js$'
              line: '\d+'
            command: "echo Running Mocha with {{filename}}:{{line}}"
      """
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js"
    And the process is still running
