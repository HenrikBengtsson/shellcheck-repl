# shellcheck-repl

## Version 0.1.1-9000 (2021-01-16)

### NEW FEATURES

 * A blocking ShellCheck warning or error can be overridden by adding two
   spaces at the end of the line.  The advantage of this over prepending a
   space at the beginning, is that it the command is preserved in the history.

 * `SHELLCHECK_REPL_SKIP_PATTERN` can now be regular expression.  It's new
   default is now "(^[[:space:]]|^\!|[[:space:]][[:space:]]$)".

 * Ignore also [SC1090] by default to avoid ShellCheck error when trying to
   source a file.
   

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
