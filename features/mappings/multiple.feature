Feature: multiple mappings

  As a developer working on a code base that uses different types of test runners or linters
  I want to be able to run different test runners on my files
  So that Tertestrial only runs the test that is important right now.

  - a mapping is a collection of mappers
  - mappings are numbered, starting with 1
  - mappings are switched via the "set_mapping" operation
  - when starting up, mapping 1 is automatically activated


  Background:
    Given a file "tertestrial.ls" with the content:
      """
      api-mapping =
        feature:
          test-file: ({filename}) -> "echo Running Cucumber for #{filename} in API mode!"
          test-line: ({filename, line}) -> "echo Running Cucumber for #{filename}:#{line} in API mode!"
        js:
          test-file: ({filename}) -> "echo Running Mocha for #{filename} in API mode!"
          test-line: ({filename, line}) -> "echo Running Mocha for #{filename}:#{line} in API mode!"

      cli-mapping =
        feature:
          test-file: ({filename}) -> "echo Running Cucumber for #{filename} in CLI mode!"
          test-line: ({filename, line}) -> "echo Running Cucumber for #{filename}:#{line} in CLI mode!"
        js:
          test-file: ({filename}) -> "echo Running Mocha for #{filename} in CLI mode!"
          test-line: ({filename, line}) -> "echo Running Mocha for #{filename}:#{line} in CLI mode!"

      mappings:
        * api-mapping
        * cli-mapping
      """
    And starting tertestrial


  Scenario: default mapping
    When sending the command:
      | OPERATION | FILENAME    |
      | testFile  | foo_spec.js |
    Then I see "Running Mocha for foo_spec.js in API mode!"


  Scenario: selecting another mapping
    When sending the command:
      | OPERATION  | MAPPING |
      | setMapping | 1       |
    And sending the command:
      | OPERATION | FILENAME    |
      | testFile  | foo_spec.js |
    Then I see "Running Mocha for foo_spec.js in CLI mode!"


  Scenario: switching to a non-existing mapping
    When sending the command:
      | OPERATION  | MAPPING |
      | setMapping | 2       |
    Then I see "Error: mapping 2 does not exist"
