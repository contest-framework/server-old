Feature: built-in configurations with multiple action sets

  As a developer working on an application tested using Cucumber-JS and Mocha
  I want to be able to run them via Ternestrial without much explicit configuration
  So that I don't waste time with redundant environment setup.

  - set the configuration to "js-cucumber-mocha" to configure Tertestrial for that setup


  Scenario Outline: using the built-in "js-cucumber-mocha-api-cli" configuration with default action set
    Given Tertestrial is running inside the "js-cucumber-mocha-api-cli" example application
    When sending filename "<FILENAME>" and line "<LINE>"
    Then I see "<TEST-COMMAND>"
    And the process is still running

    Examples:
      | FILENAME             | LINE | TEST-COMMAND                                                         |
      | features/one.feature |      | bin/cuc-api features/one.feature && bin/cuc-cli features/one.feature         |
      | features/one.feature | 123  | bin/cuc-api features/one.feature:123 && bin/cuc-cli features/one.feature:123 |
      | spec/one_spec.js     |      | node_modules/.bin/mocha spec/one_spec.js                                               |
      | spec/one_spec.coffee |      | node_modules/.bin/mocha --compilers coffee:coffee-script spec/one_spec.coffee          |
      | spec/one_spec.ls     |      | node_modules/.bin/mocha --compilers ls:livescript spec/one_spec.ls                     |
