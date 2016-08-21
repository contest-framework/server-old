Feature: tests start immediately

  As a developer kicking off a test
  I want that it starts right away without waiting for the current test to finish
  So that I don't get slowed down by currently running tests I no longer need.

  - when Tertestrial receives the signal to run a test,
    it terminates the currently running test and starts the new one right away


  Scenario: Tertestrial receives a test command while another test is still running
    Given Tertestrial is running inside the "long-running-tests" example application
    When sending the command:
      """
      {}
      """
    Then the long-running test is running
    When sending the command:
      """
      {"filename": "foo"}
      """
    Then the long-running test is no longer running
    And I see "Testing foo"
