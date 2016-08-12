# Tertestrial Release Notes

## Master

- links to [Atom package](https://github.com/charlierudolph/tertestrial-atom)
- the setup wizard is now run via a command (`tertestrial setup`) instead of a switch (`tertestrial --setup')
- drains the existing named pipe on startup: this re-activates frozen clients that were trying to use Tertestrial before it was started
- new configuration file format with explicit `match` section
- server does not terminate on errors at runtime anymore, but prints visible error messages
