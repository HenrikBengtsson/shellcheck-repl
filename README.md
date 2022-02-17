[![shellcheck](https://github.com/HenrikBengtsson/shellcheck-repl/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/HenrikBengtsson/shellcheck-repl/actions/workflows/shellcheck.yml)

# Shellcheck REPL: Validation of Shell Commands Before Evaluation

[ShellCheck] is a great tool for validating your Unix shell scripts.  It will parse the scripts and warn about mistakes, errors, and potential problems.  This tool - **shellcheck-repl** - brings ShellCheck validation to the [Bash] read-eval-print loop (REPL), i.e. the [Bash] prompt.  Getting this type of validation and feedback at the prompt lowers the risk of damaging mistakes and will help you become a better Bash user and developer.
 
The **shellcheck-repl** tool injects itself into the Bash REPL where it intercepts the read command line, validates the content via ShellCheck, and if it is all OK, then the command is evaluated and printed as usual.  However, if there is a mistake, then the command will _not_ be evaluated and an informative error message is displayed instead.  For example, assume we do:

```sh
$ words="lorem ipsum dolor"
$ for w in "$words"; do echo $w; done
```

Although this looks like a simple for loop, it might not be clear to you what the outcome of it will be.  What values will `$w` take?  However, with **shellcheck-repl** enabled, we will get the following if we try call it:

```sh
$ for w in "$words"; do echo "$w"; done
           ^-- SC2066: Since you double quoted this, it will
	       not word split, and the loop will only run once.
```

So, what [SC2066] suggests is that the output will be a single line `lorem ipsum dolor` and not three words on three separate lines.  We probably meant to use:
```sh
$ for w in $words; do echo "$w"; done
lorem
ipsum
dolor
```


## Bypassing the ShellCheck validation

You can bypass the ShellCheck validation by appending two spaces to the command with.  For instance, assume we get:

```sh
$ words="lorem ipsum dolor"
$ echo $words
       ^-- SC2086: Double quote to prevent globbing and word splitting.
```
Ideally we should call:
```sh
$ echo "$words"
lorem ipsum dolor
```
but if we find that too tedious, we can skip the validation by appending two or more spaces at the end:
```sh
$ echo $words␣␣
lorem ipsum dolor
```

By the way, one example where [SC2086] is crucial is when you work with filenames.  Using:
```sh
$ rm $file␣␣
```
can be very risky if `$file` contains spaces - in addition to not removing the file intended, you might end up removing files that you did not intend to remove.


## Disable and enable checks

To disable the ShellCheck REPL tool, do:

```sh
$ sc_repl_disable
```

To reenable it, do:

```sh
$ sc_repl_enable
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
 * [SC1090]: Can't follow non-constant source. Use a directive to specify location.
 * [SC2034]: 'var' appears unused. Verify it or export it.
 * [SC2154]: 'var' is referenced but not assigned.
 * [SC2164]: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.

This set of rules that are disabled by default can be configured via environment variable `SHELLCHECK_REPL_EXCLUDE` by specifying rules (without `SC` prefix) as a comma-separated list.  The default corresponds to `SHELLCHECK_REPL_EXCLUDE=1001,1090,2034,2154,2164`.


## Requirements

* [ShellCheck]
* [Bash] (>= 4.4) (the only supported shell right now)


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
[SC2066]: https://github.com/koalaman/shellcheck/wiki/SC2066
[SC2086]: https://github.com/koalaman/shellcheck/wiki/SC2086
[SC1001]: https://github.com/koalaman/shellcheck/wiki/SC1001
[SC1090]: https://github.com/koalaman/shellcheck/wiki/SC1090
[SC2034]: https://github.com/koalaman/shellcheck/wiki/SC2034
[SC2154]: https://github.com/koalaman/shellcheck/wiki/SC2154
[SC2164]: https://github.com/koalaman/shellcheck/wiki/SC2164
