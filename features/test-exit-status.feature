Feature: repeating the last test

  As a developer running a test that does not output
  I want to be notified when the test finishes
  So I know when I can move onto the next task

  - when Tertestrial finishes running a test, it outputs the exit code

  Background:
    Given Tertestrial is running inside the "no-output-tests" example application


  Scenario: with a test that succeeds
    When sending the command:
      """
      {"filename": "foo"}
      """
    Then I see "run-test-success"
    And I see "Exit Code: 0"


  Scenario: without a previous test
    When sending the command:
      """
      {"filename": "bar"}
      """
    Then I see "run-test-failure"
    And I see "Exit Code: 1"
