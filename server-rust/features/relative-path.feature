Feature: commands are run with relative paths

  As a developer using an editor plugin that sends absolute paths
  I want tertestrial to run my commands with the relative paths
  So my tools work properly and I don't see absolute paths

  - tertestrial converts filenames that are absolute paths to the relative path
    from the directory tertestrial is running in


  Scenario:
    Given Tertestrial is running inside the "js-cucumber-mocha" example application
    When sending the filename as the absolute path of "features/one.feature"
    Then I see "cucumber-js features/one.feature"
    And the process is still running
