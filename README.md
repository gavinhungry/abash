abash
=====
Useful functions for bash shell scripts.

Usage
-----

```sh
[ ${_ABASH:-0} -ne 0 ] || source $(dirname "${BASH_SOURCE[0]}")/abash/abash.sh
```

Functions
---------

| Function | Description |
|---|---|
| `usage` | Print a usage message to stderr and exit |
| `pref` | Check if a preference variable is set to 1 |
| `arg` | Parse command-line arguments with long/short flag support and optional defaults |
| `arge` | Check if a command-line flag exists |
| `pfarg` | Echo a long flag if the argument exists |
| `nfargs` | Return all non-flag arguments |
| `fnfarg` | Return the first non-flag argument |
| `istty` | Check if stdout is a TTY |
| `ispty` | Check if connected to a pseudo-terminal |
| `tmpdirp` | Create a persistent temporary directory |
| `tmpdir` | Create a unique temporary directory per invocation |
| `tmpdirclean` | Remove all temporary directories created by the script |
| `quietly` | Suppress command output unless `--verbose` is set |
| `color` | Set terminal color using tput |
| `msg` | Print a formatted message with the program name |
| `inform` | Print a green informational message |
| `err` | Print a red error message to stderr |
| `warn` | Print a yellow warning message to stderr |
| `banner` | Print a banner with red text on blue background |
| `bannerline` | Print a banner spanning the terminal width |
| `die` | Print an error message and exit |
| `checksu` | Verify sudo privileges and optionally run a command |
| `sigint` | Set up a SIGINT trap that exits on Ctrl-C |
| `isint` | Check if a value is an integer |
| `piduser` | Get the owner of a process by PID |
| `pidofuser` | Find PIDs of a command owned by a specific user |
| `pidpid` | Resolve a process name to a PID |
| `running` | Check if a process is currently running |
| `nwhich` | Find a program in PATH, excluding the current script |
| `confirm` | Prompt for yes/no confirmation |
| `includes` | Check if an array contains a value |
| `split` | Split input by a delimiter into lines |
| `xsleep` | Sleep using the bash loadable builtin |
| `fmpath` | Find the first file containing an exact string match |
| `fmpathdir` | Get the directory of the first file containing an exact string match |
| `hr` | Print a horizontal rule spanning the terminal width |
| `pause` | Wait for the user to press any key |
| `enpad` | Pad a string to a given length with en-spaces |
| `njoin` | Join lines into a single line with a delimiter |

License
-------
This software is released under the terms of the **MIT license**. See `LICENSE`.
