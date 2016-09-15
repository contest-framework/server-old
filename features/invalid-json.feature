Feature: invalid json

  As a Tertestrial editor plugin developer
  I want to get helpful error messages when my plugin sends invalid JSON
  So that I can quickly pinpoint and fix the problem with my code.

  - When tertestrial reads invalid json in the pipe, it reports the error and keeps running

  Background:
    Given Tertestrial is running inside the "js-cucumber-mocha" example application


  Scenario: with a previous test
    When sending the command:
      """
      {"repeatLastTest": true}{"repeatLastTest": true}
      """
    Then I see:
      """
      Error: Invalid command: {"repeatLastTest": true}{"repeatLastTest": true}
      SyntaxError: Unexpected token {
      """
    And the process is still running
