Feature: interrupting long-running tests

  As a user accidentally starting a long-running test that I didn't mean to
  I want to be able to stop it and start a shorter test without having to wait for the long test to finish
  So that I don't get slowed down by the test runner when I do mistakes.

  - when Tertestrial receives the signal to run a test,
    it terminates the currently running test and starts the new one right away


  Scenario: Tertestrial receives a test command while another test is still running
    Given Tertestrial is running inside the "long-running-tests" example application
    When sending the command:
      """
      {}
      """
    Then I see "Testing everything"
    And I don't see "Testing foo"
    When sending the command:
      """
      {"filename": "foo"}
      """
    Then I see "exiting the long-running test"
    And I see "Testing foo"
