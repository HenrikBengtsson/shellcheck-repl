#!/usr/bin/env bash

#' ShellCheck Read-Eval-Print Loop (REPL)
#'
#' Validation of Shell Commands Before Evaluation
#'
#' Usage/Install:
#' source shellcheck-repl.bash
#'
#' License: ISC
#' Home page: https://github.com/HenrikBengtsson/shellcheck-repl

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
    local skip_pattern
    
    ## Skip ShellCheck? Default is to skip with leading:
    ## * ^!           (history expansion)
    ## * ^SPACE       (in-house rule)
    ## * DOUBLESPACE$ (in-house rule)
    skip_pattern=${SHELLCHECK_REPL_SKIP_PATTERN:-(^[[:space:]]|^\!|[[:space:]][[:space:]]$)}
    if [[ "$READLINE_LINE" =~  $skip_pattern ]]; then
        return
    fi
    
    local opts=("--shell=bash" "--external-sources")
    if [[ -n "${SHELLCHECK_REPL_EXCLUDE}" ]]; then
        opts+=("--exclude=${SHELLCHECK_REPL_EXCLUDE}")
    fi
    # Option -C/--color requires ShellCheck (>= 0.4.2)
    if version_gt "${SHELLCHECK_VERSION}" 0.4.1; then
        opts+=("--color=always")
    fi
    # Option -S/--severity requires ShellCheck (>= 0.6.0)
    if version_gt "${SHELLCHECK_VERSION_X_Y}" 0.5; then
        opts+=("--severity=${SHELLCHECK_REPL_VERIFY_LEVEL:=info}")
    fi
    # Filter the output of shellcheck by removing filename
    local style=${SHELLCHECK_REPL_INFO,,}
    if [[ -z "${style}" ]]; then style="clean"; fi
    case ${style} in
        raw-tty)
	    shellcheck "${opts[@]}" --format=tty <(printf '%s\n' "$READLINE_LINE")
	    ;;
        raw-gcc)
	    shellcheck "${opts[@]}" --format=gcc <(printf '%s\n' "$READLINE_LINE")
	    ;;
        full)
	    shellcheck "${opts[@]}" <(printf '%s\n' "$READLINE_LINE") | tail -n +2
	    ;;
        clean)
	    shellcheck "${opts[@]}" <(printf '%s\n' "$READLINE_LINE") | sed -n '1,2b; /^$/q; p'
	    ;;
        note)
	    shellcheck "${opts[@]}" --format=gcc <(printf '%s\n' "$READLINE_LINE") | cut -d : -f 4- ;;
	*)
	    >&2 echo "ERROR: Unknown value for shellcheck-repl variable 'SHELLCHECK_REPL_INFO' (valid values are 'raw', 'full', 'short' and 'clean' [default]): '${SHELLCHECK_REPL_INFO}'"
	    ;;
    esac
    if [[ "${PIPESTATUS[0]}" != 0 ]]; then
	>&2 echo
	>&2 echo "To skip a check, add its SC number to 'SHELLCHECK_REPL_EXCLUDE', e.g."
	>&2 echo
	>&2 echo "  export SHELLCHECK_REPL_EXCLUDE=\"\${SHELLCHECK_REPL_EXCLUDE},4038\""
	>&2 echo
	>&2 echo "Currently, SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE}"
	>&2 echo

        ## Execute shell command: sc_repl_verify_bind_accept
        ## Triggered by key sequence: Ctrl-x Ctrl-b 2
        bind -x '"\C-x\C-b2": sc_repl_verify_bind_accept'
    fi
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
    ## SC1090: Can't follow non-constant source. Use a directive to specify
    ##         location.
    ## SC2034: 'var' appears unused. Verify it or export it.
    ## SC2154: 'var' is referenced but not assigned.
    ## SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE:-1001,1090,2034,2154,2164}
    sc_repl_enable
}

sc_wiki_url() {
    echo "https://github.com/koalaman/shellcheck/wiki/$1"
}

sc_repl_setup
