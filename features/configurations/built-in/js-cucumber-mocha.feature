Feature: built-in configurations with simple action sets

  As a developer working on an application tested using Cucumber-JS and Mocha
  I want to be able to run them via Tertestrial without much explicit configuration
  So that I don't waste time with redundant environment setup.

  - set the actions to "js-cucumber-mocha" to configure Tertestrial for that setup


  Scenario Outline: using the built-in "js-cucumber-mocha" configuration
    Given Tertestrial is running inside the "js-cucumber-mocha" example application
    When sending filename "<FILENAME>" and line "<LINE>"
    Then I see "<RESULTING-TEST-COMMAND>"
    And the process is still running

    Examples:
      | FILENAME             | LINE | RESULTING-TEST-COMMAND                                      |
      | features/one.feature |      | cucumber-js features/one.feature                            |
      | features/one.feature | 123  | cucumber-js features/one.feature:123                        |
      | spec/one_spec.js     |      | mocha spec/one_spec.js                                      |
      | spec/one_spec.coffee |      | mocha --compilers coffee:coffee-script spec/one_spec.coffee |
      | spec/one_spec.ls     |      | mocha --compilers ls:livescript spec/one_spec.ls            |
