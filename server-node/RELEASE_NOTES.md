# Tertestrial Release Notes

## 0.3.2

- store command even if there is no matching action

## 0.3.1

- support commands with leading / trailing newlines

## 0.3.0

- **BREAKING CHANGE**: update configuration structure for multiple action sets

  - the named action sets should now just be keys on the actions object instead of nested arrays

    ```yml
    # 0.2.0
    actions:
      - headless:
        # ...
      - firefox:
        # ...

    # 0.3.0
    actions:
      headless:
        # ...
      firefox:
        # ...
    ```

- gracefully handle invalid json and multiple lines of json

## 0.2.0

- add support for new command, `{"cycleActionSet": "next"}`, to cycle through action sets

## 0.1.3

- convert absolute path filenames to relative paths

## 0.1.2

- uses `bundle exec` in Ruby templates
- built-in templates provide the path to commands run
- aborts when detecting a currently running process
- add `help` and `version` command-line commands

## 0.1.1

- output the exit code of tests

## 0.1

- **BREAKING CHANGE**: update "repeatLastTest" command to new format
  - changed from `{"operation": "repeatLastTest"}` to `{"repeatLastTest": true}`
- compatibility with Node 4 in addition to 5 and 6
- terminates the currently running test before starting a new one

## 0.0.7

- more robust behavior when installed as a global module
- allow configuration file to be in any format
- update notification when new versions are available
- automatically re-runs the last test when switching action sets
- automatically reloads configuration file when it is updated
- removes the named pipe when the program ends
- shows warning when running in directory with existing named pipe

## 0.0.6

- links to [Atom package](https://github.com/charlierudolph/tertestrial-atom)
- the setup wizard is now run via a command (`tertestrial setup`) instead of a switch (`tertestrial --setup')
- drains the existing named pipe on startup: this re-activates frozen clients that were trying to use Tertestrial before it was started
- new configuration file format with explicit `match` section
- server does not terminate on non-critical errors at runtime anymore
- action sets can be switched by name in addition to number now
