SHELL:=/bin/bash

check:
	@echo "Validating shell scripts using ShellCheck $$(shellcheck --version | grep -iE "^version" | sed 's/://'):"
	@shellcheck shellcheck-repl.bash
	@echo "All OK"
