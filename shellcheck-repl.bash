#!/usr/bin/env bash

## Source: https://github.com/koalaman/shellcheck/issues/1535
sc_version() {
    if [ -z "${SHELLCHECK_VERSION+x}" ]; then
        # Example: '0.4.6'
        SHELLCHECK_VERSION=$(shellcheck --version | sed -nE 's/version: +(.+)/\1/p')
        # Example: '0.4'
        SHELLCHECK_VERSION_X_Y="${SHELLCHECK_VERSION%.*}"
    fi
}

version_gt() {
    test "$(printf '%s\n' "$@" | sort --version-sort | head -n 1)" != "$1"
}

sc_repl_verify_or_unbind() {
    local opts=("--shell=bash" "--external-sources")
    if [[ -n "${SHELLCHECK_REPL_EXCLUDE}" ]]; then
        opts+=("--exclude=${SHELLCHECK_REPL_EXCLUDE}")
    fi
    # Option -S/--severity requires ShellCheck (>= 0.6.0)
    if version_gt "${SHELLCHECK_VERSION_X_Y}" 0.5; then
        opts+=("--severity=${SHELLCHECK_REPL_VERIFY_LEVEL:=info}")
    fi
    ## Execute shell command: sc_repl_verify_bind_accept
    ## Triggered by key sequence: Ctrl-x Ctrl-b 2
    shellcheck "${opts[@]}" <(printf '%s\n' "$READLINE_LINE") ||
        bind -x '"\C-x\C-b2": sc_repl_verify_bind_accept'
}

sc_repl_verify_bind_accept() {
    ## Execute shell command: accept-line
    ## Triggered by key sequence: Ctrl-x Ctrl-b 2
    bind '"\C-x\C-b2": accept-line'
}

sc_repl_enable() {
    sc_repl_verify_bind_accept

    ## Execute shell command: sc_repl_verify_or_unbind()
    ## Triggered by key sequence: Ctrl-x Ctrl-b 1
    bind -x '"\C-x\C-b1": sc_repl_verify_or_unbind'
    
    ## Execute keystrokes: Ctrl-x Ctrl-b 1 Ctrl-x Ctrl-b 2
    ## Triggered by key sequence: Ctrl-m (Carriage Return)
    bind '"\C-m": "\C-x\C-b1\C-x\C-b2"'
}

sc_repl_disable() {
    ## Execute shell command: accept-line
    ## Triggered by key sequence: Ctrl-m (Carriage Return)
    bind '"\C-m": accept-line'
}

sc_repl_setup() {
    sc_version
    ## Ignore some ShellCheck issues:
    ## SC1001: This \= will be a regular '=' in this context.
    ## SC2034: 'var' appears unused. Verify it or export it.
    ## SC2154: 'var' is referenced but not assigned.
    ## SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    SHELLCHECK_REPL_EXCLUDE=1001,2034,2154,2164
    sc_repl_enable
}

sc_repl_setup
