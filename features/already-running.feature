Feature: abort if already running

  As a developer accidentally starting another copy of Tertestrial in a repo
  I want to be prevented from doing so
  So I don't start duplicate processes

  - Tertestrial will not start a second process if it finds another process is
    already running in the same directory


  Scenario:
    Given Tertestrial is running
    When trying to start tertestrial
    Then I see:
      """
      Tertestrial is already running in the current directory.
      """
    And the initial process is still running
