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

## Bypassing the ShellCheck validation

You can bypass the ShellCheck validation by preceeding the command with one or more leading spaces.  For instance, the following will _not_ be run through ShellCheck:

```sh
$  echo $files
a b c
$
```



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