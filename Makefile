SHELL=bash

check: shellcheck spelling

shellcheck:
	@echo "Validating shell scripts using ShellCheck $$(shellcheck --version | grep -iE "^version" | sed 's/://'):"
	@shellcheck shellcheck-repl.bash
	@echo "All OK"

spelling:
	Rscript -e "spelling::spell_check_files('README.md', ignore=readLines('WORDLIST'))"
