# shellcheck-repl

## Version 0.1.4-9003 (2022-02-18)

### NEW FEATURES

* Now checking with rule SC2154 ('var' is referenced but not assigned).
  This is achieved by providing ShellCheck with a preamble of `declare -p`
  specifications for any variables of in the expression.

* Now rule SC2178 (Variable was used as an array but is now assigned a
  string.) works. This is achieved by providing ShellCheck with a preamble of
  `declare -p` specifications for any variables assigned in the expression.


## Version 0.1.4 (2022-02-17)

### BUG FIX

 * scl_enable() would output "ERROR: No such keybinding: \C-x\C-b2", which
   was harmless.


## Version 0.1.3 (2022-02-17)

### NEW FEATURES

 * Ignore also [SC2155] by default to allow for 'export FOO=$(something)'.

 * The tool now asserts that Bash (>= 4.4) and 'shellcheck' are available.

 * Add internal assertions.
 
 * Add a debug mechanism for troubleshooting purposes.


## Version 0.1.2 (2021-01-16)

### NEW FEATURES

 * ShellCheck validation can be disable for the current line by adding two or
   more trailing spaces, i.e. `ls -l` will be validated but `ls -l  ` will not.
   
   space at the beginning, is that it the command is preserved in the
   command-line history.

 * `SHELLCHECK_REPL_SKIP_PATTERN` can now be regular expression.  It's new
   default is now "(^\!|[[:space:]][[:space:]]$)".

 * Ignore also [SC1090] by default to avoid ShellCheck error when trying to
   source a file.

### DEFUNCT

 * Support for disabling of ShellCheck validation by adding a *leading* space
   has been removed in favor of *two trailing spaces*.  The reason for this
   change is because the use leading spaces for this purpose conflicts with
   how `HISTCONTROL=ignorespace`, or `ignoredups`, prevents the call from
   being added to the command-line history.


## Version 0.1.1 (2019-09-09)

### NEW FEATURES

 * ShellCheck validation can be disable for the current line by adding one or
   more leading spaces, i.e. `ls -l` will be validated but ` ls -l` will not.
   This skip rule can be customize via `SHELLCHECK_REPL_SKIP_PATTERN` which
   defaults to "[[:space:]\!]", i.e. a leading space or exclamation mark.
   
 * ShellCheck validation is now skipped for history expansion via exclamation
   marks (!), e.g. `!1984` will neither be validated nor give an error.
   

## Version 0.1.0 (2019-04-17)

### SIGNIFICANT CHANGES

 * The license is ISC (by the Internet Software Consortium).
 
### NEW FEATURES

 * Use colored output if the ShellCheck version supports it.

 * Cleaner output by no longer displaying "In /dev/fd/63 line 1:".

 * ShellCheck output can be controlled by setting environment variable
  `SHELLCHECK_REPL_INFO` to `raw`, `note`, `full` or `clean` (default).
 

## Version 0.0.4 (2019-03-30)

### NEW FEATURES

 * Add support for older version of Bash.


## Version 0.0.3 (2019-03-29)

### NEW FEATURES

 * Skipping more ShellCheck check by default.


## Version 0.0.2 (2019-03-28)

### NEW FEATURES

 * Add support for ShellCheck (< 0.6.0).

 * `SHELLCHECK_REPL_EXCLUDE` controls which ShellCheck checks to skip.


## Version 0.0.1 (2019-03-28)

### NEW FEATURES

 * First implementation by xPMo in response Henrik Bengtsson's inquiry at
   [ShellCheck Issue #1535](https://github.com/koalaman/shellcheck/issues/1535).


[SC1090]: https://github.com/koalaman/shellcheck/wiki/SC1090
[SC2155]: https://github.com/koalaman/shellcheck/wiki/SC2155
