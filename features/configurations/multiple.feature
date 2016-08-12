Feature: multiple action sets

  As a developer working on a code base that uses different types of test runners or linters
  I want to be able to run different test runners on my files
  So that Tertestrial only runs the test that is important right now.

  - an action set is a collection of actions
  - action sets are numbered, starting with 1
  - action sets are switched via the "actionSet" command
  - when starting up, the first action set is automatically activated


  Background:
    Given Tertestrial runs with the configuration:
      """
      actions:

        - 'API':

          - match:
              filename: '\.feature$'
            command: "echo Running Cucumber for {{filename}} in API mode!"

          - match:
              filename: '\.feature$'
              line: '\d+'
            command: "echo Running Cucumber for {{filename}}:{{line}} in API mode!"

          - match:
              filename: '\.js$'
            command: "echo Running Mocha for {{filename}} in API mode!"

          - match:
              filename: '\.js$'
              line: '\d+'
            command: "echo Running Mocha for {{filename}}:{{line}} in API mode!"

        - 'CLI':

          - match:
              filename: '\.feature$'
            command: "echo Running Cucumber for {{filename}} in CLI mode!"

          - match:
              filename: '\.feature$'
              line: '\d+'
            command: "echo Running Cucumber for {{filename}}:{{line}} in CLI mode!"

          - match:
              filename: '\.js$'
            command: "echo Running Mocha for {{filename}} in CLI mode!"

          - match:
              filename: '\.js$'
              line: '\d+'
            command: "echo Running Mocha for {{filename}}:{{line}} in CLI mode!"
      """


  Scenario: default action set
    When sending the command:
      """
      {"filename": "foo_spec.js"}
      """
    Then I see "Running Mocha for foo_spec.js in API mode!"


  Scenario: selecting another action set
    When sending the command:
      """
      {"filename": "foo_spec.js"}
      """
    Then I see "Running Mocha for foo_spec.js in API mode!"
    When sending the command:
      """
      {"actionSet": 2}
      """
    Then I see "Activating action set CLI"
    And sending the command:
      """
      {"operation": "repeatLastTest"}
      """
    Then I see "Running Mocha for foo_spec.js in CLI mode!"


  Scenario: switching to a non-existing action set
    When sending the command:
      """
      {"actionSet": 3}
      """
    Then I see "Error: action set 3 does not exist"
