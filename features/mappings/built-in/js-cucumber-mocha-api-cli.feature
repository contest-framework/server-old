Feature: built-in mappers

  As a developer working on an application tested using Cucumber-JS and Mocha
  I want to be able to run them via Ternestrial without much explicit configuration
  So that I don't waste time with redundant environment setup.

  - set the mapping to "js-cucumber-mocha" to configure Tertestrial for that setup


  Scenario Outline: using the built-in "js-cucumber-mocha-api-cli" mapping with default mapping
    Given Tertestrial is running inside the "js-cucumber-mocha-api-cli" example application
    When sending the operation "<OPERATION>" on filename "<FILENAME>" and line "<LINE>"
    Then I see "<TEST-COMMAND>"

    Examples:
      | OPERATION | FILENAME             | LINE | TEST-COMMAND                                                         |
      | testFile  | features/one.feature |      | cuc-api features/one.feature && cuc-cli features/one.feature         |
      | testLine  | features/one.feature | 123  | cuc-api features/one.feature:123 && cuc-cli features/one.feature:123 |
      | testFile  | spec/one_spec.js     |      | mocha spec/one_spec.js                                               |
      | testFile  | spec/one_spec.coffee |      | mocha --compilers coffee:coffee-script spec/one_spec.coffee          |
      | testFile  | spec/one_spec.ls     |      | mocha --compilers ls:livescript spec/one_spec.ls                     |
