Feature: Help screen

  As a developer forgetting how to use Tertestrial
  I want quick access to a help screen
  So that I can be reminded how the command works.

  - run "tertestrial help" to display a help screen


  Scenario: displaying the help screen
    When running 'tertestrial help'
    Then I see:
      """
      Usage:
        tertestrial
        tertestrial (help | setup | version)

      Subcommands:
        help      Show this screen
        setup     Run a setup wizard to generate a config file
        version   Show version
      """
