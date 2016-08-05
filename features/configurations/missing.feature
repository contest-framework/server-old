Feature: error message for missing configuration file


  Scenario: configuration file missing
    When trying to start tertestrial
    Then I see "Error: cannot find configuration file"
