Feature: drains existing pipe

  As a developer starting Tertestrial after a crash
  I want the pipe to be drained and recreated
  So that I can start fresh

  - when Tertestrial detects an existing named pipe, it drains and re-creates a fresh pipe

  Scenario:
    Given Tertestrial is starting in a directory containing the file ".tertestrial.tmp"
    Then I see "running"
    And the process is still running
