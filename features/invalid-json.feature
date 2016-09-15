@verbose
Feature: invalid json

  As a developer accidentally starting another copy of Tertestrial in a repo
  I want to be prevented from doing so
  So I don't start duplicate processes

  - When tertestrial reads invalid json in the pipe, it reports the error

  Background:
    Given Tertestrial is running inside the "js-cucumber-mocha" example application


  Scenario: with a previous test
    When sending the command:
      """
      {"repeatLastTest": true}{"repeatLastTest": true}
      """
    Then I see:
      """
      Error: Invalid command:
        Command: {"repeatLastTest": true}{"repeatLastTest": true}
        SyntaxError: Unexpected token { in JSON at position 24
      """
    And the process is still running
