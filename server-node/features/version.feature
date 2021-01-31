Feature: repeating the last test

  As a Tertestrial user unsure what version is installed on the current machine
  I want to have a quick way to check the version
  So that I can decide whether to upgrade Tertestrial.

  - run "tertestrial version" to print the version


  Scenario: with a test that succeeds
    When running 'tertestrial version'
    Then I see the version
