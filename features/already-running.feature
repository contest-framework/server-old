Feature: warn if already running

  As a developer accidentally starting another copy of Tertestrial in a repo
  I want to be told that this is not recommended
  So that I avoid this mistake.

  - when Tertestrial detects an existing named pipe, it displays a warning
  - the user has the choice to abort or continue
  - if the user continues, it drains and re-creates a fresh pipe


  Background:
    Given Tertestrial is starting in a directory containing the file ".tertestrial.tmp"


  Scenario: a named pipe exists and the user chooses to abort
    Then I see:
      """
      I have found a named pipe in this directory.
      This indicates Tertestrial is either already running,
      or has crashed before.

      If Tertestrial is running for this project already,
      please hit Ctrl-C to exit this process.
      Otherwise hit Enter to continue.
      """


  Scenario: a named pipe exists and the user chooses to continue
    When I hit the Enter key
    Then I see "running"
    And the process is still running
