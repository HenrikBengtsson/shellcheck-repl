SHELL:=/bin/bash

check:
	@echo "* Validating shell scripts"
	shellcheck --version
	shellcheck shellcheck-repl.bash
