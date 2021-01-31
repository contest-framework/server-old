Feature: Stopping the currently running test

  As a Tertestrial user having accidentally started a long test run
  I want to be able to kill the currently running test
  So that I don't have to wait for it to finish before being able to use my terminal again.

  - send '{"stopCurrentTest": true}' to stop the currently running tests
  - if no test is running, this command does nothing


  Scenario: stopping a running test
    Given Tertestrial is running a long-running test
    When sending the command:
      """
      {"stopCurrentTest": true}
      """
    Then I see "stopping the currently running command"
    And the process is still running


  Scenario: test is no longer running
    Given Tertestrial had been running a test
    When sending the command:
      """
      {"stopCurrentTest": true}
      """
    Then I see "the last command has finished already"
    And the process is still running


  Scenario: no previous test
    Given Tertestrial is running
    When sending the command:
      """
      {"stopCurrentTest": true}
      """
    Then I see "no command run so far"
    And the process is still running


  Scenario: process was killed already
    Given Tertestrial is running a long-running test
    When sending the command:
      """
      {"stopCurrentTest": true}
      """
    And sending the command:
      """
      {"stopCurrentTest": true}
      """
    Then I see "you have already stopped the last command"
    And the process is still running
