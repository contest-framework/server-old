Feature: multiple commands

  As a developer doing a find and replace with auto-test on
  I want tertestrial to be able to handle receieving multiple commands at once and just run the last
  So that I see only the result of my most recent command

  - When tertestrial reads multiple commands at once, it ignores all but the last


  Background:
    Given Tertestrial is running inside the "js-cucumber-mocha" example application


  Scenario:
    When sending the command:
      """
      {"filename": "features/one.feature"}
      {"filename": "features/two.feature"}
      """
    Then I see "cucumber-js features/two.feature"
    And the process is still running
