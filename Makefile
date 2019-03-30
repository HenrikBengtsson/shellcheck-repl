SHELL:=/bin/bash

check:
	@echo "* Validating shell scripts"
	shellcheck shellcheck-repl.bash
