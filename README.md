# shellcheck-repl: Validation of Shell Commands Before Evaluation


## Examples

```sh
$ rm  $files

In /dev/fd/63 line 1:
rm $files
   ^-- SC2086: Double quote to prevent globbing and word splitting.

$ rm "$files"

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
$ echo ". /path/to/software/shellcheck-repl.bash" >> ~/.bashrc
```


## Authors

* Original code by GitHub user [xMpo](https://github.com/xPMo)
* Henrik Bengtsson
