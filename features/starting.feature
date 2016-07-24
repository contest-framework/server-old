Feature: starting

  As a developer starting the Tertestrial server
  I want to be given instructions how to end it
  So that I know how to terminate it safely.

  - when Tertestrial starts, it prints how to exit it


  Scenario: starting in foreground
    When running "tertestrial"
    Then I see "ctrl-c to exit"
