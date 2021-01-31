Feature: repeating the last test

  As a developer having made some adjustments to my code base
  I want to be able to easily repeat the last run test
  So that I can verify whether my code and tests work now.

  - send '{"repeatLastTest": true}' to repeat the last test


  Background:
    Given Tertestrial is running inside the "js-cucumber-mocha" example application


  Scenario: with a previous test
    When sending the command:
      """
      {"filename": "features/one.feature"}
      """
    Then I see "cucumber-js features/one.feature"
    When sending the command:
      """
      {"repeatLastTest": true}
      """
    Then I see "cucumber-js features/one.feature"
    And the process is still running


  Scenario: with a previous test that didn't match any actions
    When sending the command:
      """
      {"filename": "README.md"}
      """
    Then I see "Error: no matching action"
    When sending the command:
      """
      {"repeatLastTest": true}
      """
    Then I see "Error: no matching action"
    And the process is still running


  Scenario: without a previous test
    When sending the command:
      """
      {"repeatLastTest": true}
      """
    Then I see "No previous test run"
    And the process is still running
