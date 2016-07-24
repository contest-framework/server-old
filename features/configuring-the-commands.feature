Feature: configuring the commands

  As a developer using Tertestrial
  I want to be able to configure how my files are tested
  So that I can use Tertestrial with my own test tools.

  - Tertestrial is configured via a file "tertestrial.config"
    in the root directory of the project
  - this file defines a number of Bash functions that print the command to run
    for different situations


  Scenario: simple configuration file
    Given a file "tertestrial.config" with the content:
      """
      #!/usr/bin/env bash

      function command_for_test_foo {
        echo "echo testing file $filename"
      }

      function command_for_test_line_foo {
        echo "echo testing file $filename:$line"
      }
      """
    When running "tertestrial"
    And sending the command:
      | OPERATION | FILETYPE | FILENAME |
      | test      | foo      | one.foo  |
    Then I see "testing file one.foo"


  Scenario: configuration file missing
    When running "tertestrial"
    Then I see "Cannot find configuration file tertestrial.config"
