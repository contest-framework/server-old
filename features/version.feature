Feature: repeating the last test

  Scenario: with a test that succeeds
    When I run 'tertestrial --version'
    Then I see the version
