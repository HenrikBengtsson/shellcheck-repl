[![Build Status](https://travis-ci.org/HenrikBengtsson/shellcheck-repl.svg?branch=master)](https://travis-ci.org/HenrikBengtsson/shellcheck-repl)

# shellcheck-repl: Validation of Shell Commands Before Evaluation

[ShellCheck] is a great tool for validating your Unix shell scripts.  It will parse the scripts and warn about mistakes, errors, and potential problems.

This tool - **shellcheck-repl** - brings the same validation to the [Bash] prompt.  It does so by intercepting the command line, validates the entered command line via ShellCheck, and if it is all OK, then the command is evaluated as usual.  However, if there is a mistake, then the command will _not_ be evaluated and an informative error message is instead given.  For example,

```sh
$ files="a b c"
$ echo $files
echo $files
   ^-- SC2086: Double quote to prevent globbing and word splitting.
$ echo "$files"
a b c
$
```

Hint: See [SC2086] for more details on that error.


## Bypassing the ShellCheck validation

You can bypass the ShellCheck validation by preceding the command with one or more leading spaces.  For instance, the following will _not_ be run through ShellCheck:

```sh
$  echo $files
a b c
$
```


## Settings

### ShellCheck rules to ignore

Some of the ShellCheck rules may be too tedious to follow when on the command line.  For example, when trying to change directory to a non-existing directory, `cd` will produce a non-zero exit code.  If you do not handle this type of error in a script, ShellCheck will report on [SC2164];
```sh
cd /path/to
^-- SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
```

The suggestion is really valid for scripts, but for the command line is is just annoying.  Because of this, **shellcheck-repl** disables the check for SC2164 by default.  In addition, it also disables the validation of other ShellCheck rules that are too tedious or simply false-positives when used at the command line:

 * [SC1001]: This \= will be a regular '=' in this context.
 * [SC2034]: 'var' appears unused. Verify it or export it.
 * [SC2154]: 'var' is referenced but not assigned.
 * [SC2164]: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.

This set of rules that are disabled by default can be configured via environment variable `SHELLCHECK_REPL_EXCLUDE` by specifying rules (without `SC` prefix) as a comma-separated list.  The default corresponds to `SHELLCHECK_REPL_EXCLUDE=1001,2034,2154,2164`.



## Requirements

* [ShellCheck]
* [Bash] (the only supported shell right now)


## Installation

Download the `shellcheck-repl.bash` script and source it in your `~/.bashrc` startup script, e.g.

```sh
$ cd /path/to/software
$ git clone https://github.com/HenrikBengtsson/shellcheck-repl.git
$ echo ". /path/to/software/shellcheck-repl/shellcheck-repl.bash" >> ~/.bashrc
```


## Authors

* GitHub user [xPMo](https://github.com/xPMo) - original code
* Henrik Bengtsson


[ShellCheck]: https://github.com/koalaman/shellcheck
[Bash]: https://www.gnu.org/software/bash/
[SC2086]: https://github.com/koalaman/shellcheck/wiki/SC2086
[SC1001]: https://github.com/koalaman/shellcheck/wiki/SC1001
[SC2034]: https://github.com/koalaman/shellcheck/wiki/SC2034
[SC2154]: https://github.com/koalaman/shellcheck/wiki/SC2154
[SC2164]: https://github.com/koalaman/shellcheck/wiki/SC2164
