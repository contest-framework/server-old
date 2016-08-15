# Tertestrial Release Notes

## Master

- more robust behavior when installed as a global module
- allow configuration file to be in any format
- update notification when new versions are available
- automatically re-runs the last test when switching action sets
- automatically reloads configuration file when it is updated


## 0.0.6

- links to [Atom package](https://github.com/charlierudolph/tertestrial-atom)
- the setup wizard is now run via a command (`tertestrial setup`) instead of a switch (`tertestrial --setup')
- drains the existing named pipe on startup: this re-activates frozen clients that were trying to use Tertestrial before it was started
- new configuration file format with explicit `match` section
- server does not terminate on non-critical errors at runtime anymore
- action sets can be switched by name in addition to number now
