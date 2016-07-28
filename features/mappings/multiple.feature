Feature: multiple mappings

  As a developer working on a code base that uses different types of test runners or linters
  I want to be able to run different test runners on my files
  So that Tertestrial only runs the test that is important right now.

  - a mapping is a collection of mappers
  - mappings are numbered, starting with 1
  - mappings are switched via the "set_mapping" operation
  - when starting up, mapping 1 is automatically activated


  Background:
    Given a file "tertestrial.yml" with the content:
      """
      mappings:

        - 'API':
            feature:
              testFile: "echo Running Cucumber for {{filename}} in API mode!"
              testLine: "echo Running Cucumber for {{filename}}:{{line}} in API mode!"
            js:
              testFile: "echo Running Mocha for {{filename}} in API mode!"
              testLine: "echo Running Mocha for {{filename}}:{{line}} in API mode!"

        - 'CLI':
            feature:
              testFile: "echo Running Cucumber for {{filename}} in CLI mode!"
              testLine: "echo Running Cucumber for {{filename}}:{{line}} in CLI mode!"
            js:
              testFile: "echo Running Mocha for {{filename}} in CLI mode!"
              testLine: "echo Running Mocha for {{filename}}:{{line}} in CLI mode!"
      """
    And starting tertestrial


  Scenario: default mapping
    When sending the command:
      """
      {"operation": "testFile", "filename": "foo_spec.js"}
      """
    Then I see "Running Mocha for foo_spec.js in API mode!"


  Scenario: selecting another mapping
    When sending the command:
      """
      {"operation": "setMapping", "mapping": 2}
      """
    Then I see "Activating mapping CLI"
    And sending the command:
      """
      {"operation": "testFile", "filename": "foo_spec.js"}
      """
    Then I see "Running Mocha for foo_spec.js in CLI mode!"


  Scenario: switching to a non-existing mapping
    When sending the command:
      """
      {"operation": "setMapping", "mapping": 3}
      """
    Then I see "Error: mapping 3 does not exist"
