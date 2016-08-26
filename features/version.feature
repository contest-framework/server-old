Feature: repeating the last test

  As a developer forgetting what version of tertestrial I have installed
  I want quick access to the version
  So that I can find out what version I have installed

  - run "tertestrial --version" to print the version


  Scenario: with a test that succeeds
    When I run 'tertestrial --version'
    Then I see the version
