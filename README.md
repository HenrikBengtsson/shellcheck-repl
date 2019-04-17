[![Build Status](https://travis-ci.org/HenrikBengtsson/shellcheck-repl.svg?branch=master)](https://travis-ci.org/HenrikBengtsson/shellcheck-repl)

# shellcheck-repl: Validation of Shell Commands Before Evaluation


## Examples

```sh
$ files="a b c"
$ echo $files
echo $files
   ^-- SC2086: Double quote to prevent globbing and word splitting.
$ echo "$files"
$
```


## Requirements

* [ShellCheck](https://github.com/koalaman/shellcheck)
* Bash (the only supported shell right now)


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
