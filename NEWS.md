# shellcheck-repl

## Version (development version)

### New Features

 * Add environment variable `SHELLCHECK_REPL_ACTION`. If `enable`,
   then ShellCheck REPL is enabled and if `disable`, it is enabled. if
   `sessioninfo`, then session information is displayed.

 * Now validation is skipped immediately if input is empty, which
   happens if we just press ENTER.

 * Error messages now also include the Bash version.

### Known issues

 * Due to a bug Bash (>= 5.1 & < 5.2), ShellCheck REPL will not work
   correctly. ShellCheck REPL will produce an informative warning, if
   enabled on a buggy Bash version.

### Defunct

 * Environment variable `SHELLCHECK_REPL_INIT` is defunct. Use
   `SHELLCHECK_REPL_ACTION` instead.


## Version 0.4.0 (2022-12-17)

### Significant Changes

 * Environment variables `SC_REPL_INIT` and `SC_REPL_DEBUG` have been
   renamed to `SHELLCHECK_REPL_INIT` and `SHELLCHECK_REPL_DEBUG`.

### New Features

 * The explaination how to exclude a specific type of ShellCheck check
   that appears after an issue is detected can be disabled by setting
   environment variable `SHELLCHECK_REPL_VERBOSE` to `false`.


## Version 0.3.0 (2022-11-21)

### New Features

 * Now ignoring [SC1113], because commenting an _absolute_ path
   (e.g. `# /path/to/something` to be used later), would produce
   `SC1091 (error): Use #!, not just #, for the shebang.`


## Version 0.2.1 (2022-04-16)

### Bug Fixes

* Now ignoring [SC1091], because `p=/path/to; source "$p/foo.sh"`
  would produce `SC1091 (info): Not following: ./bin/activate:
  openBinaryFile: does not exist (No such file or directory)`.


## Version 0.2.0 (2022-02-18)

### New Features

* Now checking with rule [SC2154] ('var' is referenced but not
  assigned).  This is achieved by providing ShellCheck with a preamble
  of `declare -p` specifications for any variables of in the
  expression.

* Now rule [SC2178] (Variable was used as an array but is now assigned
  a string.) works. This is achieved by providing ShellCheck with a
  preamble of `declare -p` specifications for any variables assigned
  in the expression.


## Version 0.1.4 (2022-02-17)

### Bug Fixes

 * `scl_enable()` would output `ERROR: No such keybinding: \C-x\C-b2`,
   which was harmless.


## Version 0.1.3 (2022-02-17)

### New Features

 * Ignore also [SC2155] by default to allow for `export
   FOO=$(something)`.

 * The tool now asserts that Bash (>= 4.4) and `shellcheck` are
   available.

 * Add internal assertions.
 
 * Add a debug mechanism for troubleshooting purposes.


## Version 0.1.2 (2021-01-16)

### New Features

 * ShellCheck validation can be disable for the current line by adding
   two or more trailing spaces, i.e. `ls -l` will be validated but `ls
   -l ` will not.  In contrast, using space at the beginning, causes
   Bash to skip adding the call to its command-line history.

 * `SHELLCHECK_REPL_SKIP_PATTERN` can now be regular expression.  It's
   new default is now `"(^\!|[[:space:]][[:space:]]$)"`.

 * Ignore also [SC1090] by default to avoid ShellCheck error when
   trying to source a file.

### Defunct

 * Support for disabling of ShellCheck validation by adding a
   *leading* space has been removed in favor of *two trailing spaces*.
   The reason for this change is because the use leading spaces for
   this purpose conflicts with how `HISTCONTROL=ignorespace`, or
   `ignoredups`, prevents the call from being added to the
   command-line history.


## Version 0.1.1 (2019-09-09)

### New Features

 * ShellCheck validation can be disable for the current line by adding
   one or more leading spaces, i.e. `ls -l` will be validated but ` ls
   -l` will not.  This skip rule can be customize via
   `SHELLCHECK_REPL_SKIP_PATTERN` which defaults to `"[[:space:]\!]"`,
   i.e. a leading space or exclamation mark.
   
 * ShellCheck validation is now skipped for history expansion via
   exclamation marks (!), e.g. `!1984` will neither be validated nor
   give an error.
   

## Version 0.1.0 (2019-04-17)

### Significant Changes

 * The license is ISC (by the Internet Software Consortium).
 
### New Features

 * Use colored output if the ShellCheck version supports it.

 * Cleaner output by no longer displaying "In /dev/fd/63 line 1:".

 * ShellCheck output can be controlled by setting environment variable
  `SHELLCHECK_REPL_INFO` to `raw`, `note`, `full` or `clean`
  (default).
 

## Version 0.0.4 (2019-03-30)

### New Features

 * Add support for older version of Bash.


## Version 0.0.3 (2019-03-29)

### New Features

 * Skipping more ShellCheck checks by default.


## Version 0.0.2 (2019-03-28)

### New Features

 * Add support for ShellCheck (< 0.6.0).

 * `SHELLCHECK_REPL_EXCLUDE` controls which ShellCheck checks to skip.


## Version 0.0.1 (2019-03-28)

### New Features

 * First implementation by xPMo in response Henrik Bengtsson's inquiry
   at [ShellCheck Issue #1535].


[SC1090]: https://github.com/koalaman/shellcheck/wiki/SC1090
[SC1091]: https://github.com/koalaman/shellcheck/wiki/SC1091
[SC1113]: https://github.com/koalaman/shellcheck/wiki/SC1113
[SC2154]: https://github.com/koalaman/shellcheck/wiki/SC2154
[SC2155]: https://github.com/koalaman/shellcheck/wiki/SC2155
[SC2178]: https://github.com/koalaman/shellcheck/wiki/SC2178
[ShellCheck Issue #1535]: https://github.com/koalaman/shellcheck/issues/1535
