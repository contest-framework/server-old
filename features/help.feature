Feature: Help screen

  As a developer forgetting how to use tertestrial
  I want quick access to a help screen
  So that I can be reminded how the command works

  - run "tertestrial -h" or "tertestrial --help" to display a help screen


  Scenario Outline: displaying the help screen
    When I run 'tertestrial <flag>'
    Then I see:
      """
      Usage:
        tertestrial [options]
        tertestrial setup

      Options:
        -h, --help   Show this screen
        --version    Show version
      """

    Examples:
      | flag   |
      | -h     |
      | --help |
