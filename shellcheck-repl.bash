# On 2019-03-29, Henrik Bengtsson wrote in response to https://github.com/koalaman/shellcheck/issues/1535:
#
# I'm forced to use older versions of ShellCheck on different systems (e.g. Ubuntu 18.04 is still ShellCheck 0.4.6) and noticed that -S was introduced in 0.6.0 (2018-12-02). So, I tweaked your code to be:
#!/usr/bin/env bash

## Source: https://github.com/koalaman/shellcheck/issues/1535
function sc_version() {
    if [ -z "${SHELLCHECK_VERSION+x}" ]; then
        # Example: '0.4.6'
        SHELLCHECK_VERSION=$(shellcheck --version | grep version: | sed -E 's/version:[ ]+//')
        # Example: '0.4'
	SHELLCHECK_VERSION_X_Y="${SHELLCHECK_VERSION%.*}"
    fi
}

function version_gt() {
    test "$(printf '%s\n' "$@" | sort --version-sort | head -n 1)" != "$1"
}

function sc_repl_verify_or_unbind() {
    local opts=("--shell=bash" "--external-sources")
    if [ ! -z "${SHELLCHECK_REPL_EXCLUDE+x}" ]; then
        opts+=("--exclude=${SHELLCHECK_REPL_EXCLUDE}")
    fi
    # Option -S/--severity requires ShellCheck (>= 0.6.0)
    if version_gt "${SHELLCHECK_VERSION_X_Y}" 0.5; then
        opts+=("--severity=\"${SC_VERIFY_LEVEL:=info}\"")
    fi
    shellcheck "${opts[@]}" <(printf '%s\n' "$READLINE_LINE") ||
        bind -x '"\C-x\C-b2": sc_repl_verify_bind_accept'
}

function sc_repl_verify_bind_accept() {
    bind '"\C-x\C-b2": accept-line'
}


function sc_repl_setup() {
    SHELLCHECK_REPL_EXCLUDE=2154
    sc_version
    sc_repl_verify_bind_accept
    bind -x '"\C-x\C-b1": sc_repl_verify_or_unbind'
    bind '"\C-m":"\C-x\C-b1\C-x\C-b2"'
}


sc_repl_setup
