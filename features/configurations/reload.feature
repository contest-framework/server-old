Feature: reloading configuration

  As a Tertestrial user
  I want the tool to automatically reload its configuration
  So that I can customize my configuration without having to restart the tool manually.

  - any change to tertestrial.yml causes it to reload the configuration


  Scenario: the configuration updates without a previous test run
    Given Tertestrial runs with the configuration:
      """
      actions:
        - match:
          command: 'echo Running all tests'
      """
    When updating the configuration to:
      """
      actions:
        - match:
          command: 'echo Running all tests'

        - match:
            filename: '\.js$'
          command: 'echo Running Mocha with {{filename}}'
      """
    Then I see "Reloading configuration"
    When sending the command:
      """
      {"filename": "one.js"}
      """
    Then I see "Running Mocha with one.js"
    And the process is still running


  Scenario: the configuration updates with a previous test run
    Given Tertestrial runs with the configuration:
      """
      actions:
        - match:
          command: 'echo Running all tests'
      """
    When sending the command:
      """
      {}
      """
    Then I see "Running all tests"
    When updating the configuration to:
      """
      actions:
        - match:
          command: 'echo Running all tests'

        - match:
            filename: '\.js$'
          command: 'echo Running Mocha with {{filename}}'
      """
    Then I see "Reloading configuration"
    And I see "Running all tests"
    And the process is still running

