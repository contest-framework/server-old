Feature: generating the configuration file

  As a developer setting up Tertestrial on my code base
  I want to get assistance setting up the configuration file
  So that I can make my way through this complicated process without having to study documentation.

  - run "tertestrial --setup" to start the configuration wizard
  - the configuration wizard asks a number of questions and generates a configuration file


  Scenario: generating a custom configuration file
    When starting 'tertestrial --setup'
    And entering '[ENTER]'
    Then I see "Created configuration file tertestrial.js"
    And it creates a file "tertestrial.js"
