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

sc_repl_version() {
    echo "0.4.3-9001"
}


## Source: https://github.com/koalaman/shellcheck/issues/1535
sc_version() {
    sc_repl_debug "sc_version() ..."    
    if [ -z "${SHELLCHECK_VERSION+x}" ]; then
        # Example: '0.4.6'
        SHELLCHECK_VERSION=$(shellcheck --version | sed -nE 's/version: +(.+)/\1/p')
        # Example: '0.4'
        SHELLCHECK_VERSION_X_Y="${SHELLCHECK_VERSION%.*}"
    fi
    sc_repl_debug " - SHELLCHECK_VERSION: ${SHELLCHECK_VERSION}"
    sc_repl_debug " - SHELLCHECK_VERSION_X_Y: ${SHELLCHECK_VERSION_X_Y}"
    sc_repl_debug "sc_version() ... done"
}

version_gt() {
    test "$(printf '%s\n' "$@" | sort --version-sort | head -n 1)" != "$1"
}

SHELLCHECK_REPL_DEBUG=${SHELLCHECK_REPL_DEBUG:-false}
SHELLCHECK_REPL_VERBOSE=${SHELLCHECK_REPL_VERBOSE:-true}

sc_repl_debug() {
    $SHELLCHECK_REPL_DEBUG || return 0
    echo >&2 "DEBUG: ${*}"
}

sc_repl_debug_shell_command_keybindings() {
    $SHELLCHECK_REPL_DEBUG || return 0
    sc_repl_debug "All active shell-command keybindings per 'bind -X':"
    { bind -X 1>&2; } > /dev/null
}

sc_repl_debug_function_keybindings() {
    $SHELLCHECK_REPL_DEBUG || return 0
    sc_repl_debug "All active shell-command keybindings per 'bind -P':"
    { bind -P | grep -F "can be found on" 1>&2; } > /dev/null
}

sc_repl_debug_sequence_keybindings() {
    $SHELLCHECK_REPL_DEBUG || return 0
    sc_repl_debug "All active sequence keybindings per 'bind -s':"
    { bind -s | grep -F "can be found on" 1>&2; } > /dev/null
}

sc_repl_sessioninfo() {
    sc_version
    echo "ShellCheck REPL: $(sc_repl_version)"
    echo "ShellCheck: ${SHELLCHECK_VERSION}"
    echo "Bash: ${BASH_VERSION}"
#    echo "Bash key sequences bound to shell commands:"
#    bind -X
#    echo "Bash key sequences bound to functions:"
#    bind -P | grep "can be found"
}    

sc_repl_warning() {
    echo >&2 "WARNING: ${*} [shellcheck-repl $(sc_repl_version); bash ${BASH_VERSION}]"
    return 0
}    

sc_repl_error() {
    echo >&2 "ERROR: ${*} [shellcheck-repl $(sc_repl_version); bash ${BASH_VERSION}]"
    return 1
}    

sc_repl_assert_bash_version() {
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        sc_repl_error "ShellCheck REPL requires Bash (>= 4.4): ${BASH_VERSION}"
        return 1
    fi
    if [[ "${BASH_VERSINFO[0]}" -eq 4 ]] && [[ "${BASH_VERSINFO[1]}" -lt 4 ]]; then
        sc_repl_error "ShellCheck REPL requires Bash (>= 4.4): ${BASH_VERSION}"
        return 1
    fi
    return 0
}
                       
sc_repl_assert_shellcheck() {
    if ! command -v shellcheck &> /dev/null; then
        sc_repl_error "'shellcheck' not found"
        return 1
    fi
    return 0
}

sc_repl_assert_readline_fcn_exists() {
    if ! bind -l | grep -q -E "^${1:?}$"; then
        sc_repl_error "No such bash function: ${1}"
        return 1
    fi
    return 0
}

## Function to check whether 'bind -X' is available
## It available in Bash 4.3 (2014-02-26)
## It is not available in 4.2.53 (2014-11-07)
sc_repl_bind_has_option_X() {
    bind -X &> /dev/null
}

sc_repl_assert_shell_command_keybinding_exists() {
    sc_repl_debug "sc_repl_assert_shell_command_keybinding_exists('${1}') ..."
    ## Skip tests if 'bind -X' is not supported
    if ! sc_repl_bind_has_option_X; then
        sc_repl_debug "sc_repl_assert_shell_command_keybinding_exists('${1}') ... done"
        return 0
    fi

    if ! bind -X | grep -q -F '"'"${1:?}"'":'; then
        sc_repl_debug_shell_command_keybindings
        sc_repl_error "No such shell-command keybinding: ${1}"
        sc_repl_debug "sc_repl_assert_shell_command_keybinding_exists('${1}') ... ERROR"
        return 1
    fi
    sc_repl_debug "sc_repl_assert_shell_command_keybinding_exists('${1}') ... OK"
    return 0
}

## Function to check whether 'bind -P' is available
sc_repl_bind_has_option_P() {
    bind -P &> /dev/null
}

sc_repl_assert_function_keybinding_exists() {
    sc_repl_debug "sc_repl_assert_function_keybinding_exists('${1}') ..."
    ## Skip tests if 'bind -P' is not supported
    if ! sc_repl_bind_has_option_P; then
        sc_repl_debug "sc_repl_assert_function_keybinding_exists('${1}') ... done"
        return 0
    fi

    if ! bind -P | grep -q -F '"'"${1:?}"'"'; then
        sc_repl_debug_function_keybindings
        sc_repl_error "No such function keybinding: ${1}"
        sc_repl_debug "sc_repl_assert_function_keybinding_exists('${1}') ... ERROR"
        return 1
    fi
    sc_repl_debug "sc_repl_assert_function_keybinding_exists('${1}') ... OK"
    return 0
}

## Function to check whether 'bind -s' is available
sc_repl_bind_has_option_s() {
    bind -s &> /dev/null
}

sc_repl_assert_sequence_keybinding_exists() {
    sc_repl_debug "sc_repl_assert_sequence_keybinding_exists('${1}') ..."
    ## Skip tests if 'bind -P' is not supported
    if ! sc_repl_bind_has_option_s; then
        sc_repl_debug "sc_repl_assert_sequence_keybinding_exists('${1}') ... done"
        return 0
    fi

    if ! bind -s | grep -q -F '"'"${1:?}"'":'; then
        sc_repl_debug_sequence_keybindings
        sc_repl_error "No such sequence keybinding: ${1}"
        sc_repl_debug "sc_repl_assert_sequence_keybinding_exists('${1}') ... ERROR"
        return 1
    fi
    sc_repl_debug "sc_repl_assert_sequence_keybinding_exists('${1}') ... OK"
    return 0
}

sc_repl_asserts() {
    sc_repl_debug "sc_repl_asserts() ..."
    
    sc_repl_assert_bash_version &&
    sc_repl_assert_shellcheck &&
    sc_repl_assert_readline_fcn_exists "accept-line"
    res=$?
    sc_repl_debug "sc_repl_asserts() ... done"
    return ${res}
}    

sc_repl_verify_or_unbind() {
    local input
    local opts    
    local skip_pattern
    local style
    local start_time
    local end_time
    local vars
    local tmp

    sc_repl_debug "sc_repl_verify_or_unbind() ..."
    
    ## Nothing to do?
    if [[ -z "$READLINE_LINE" ]]; then
        sc_repl_debug " - empty input"
        sc_repl_debug "sc_repl_verify_or_unbind() ... done"
        return
    fi
    
    ## Skip ShellCheck? Default is to skip with leading:
    ## * ^!           (history expansion)
    ## * DOUBLESPACE$ (in-house rule)
    skip_pattern=${SHELLCHECK_REPL_SKIP_PATTERN:-(^\!|[[:space:]][[:space:]]$)}
    if [[ "$READLINE_LINE" =~  $skip_pattern ]]; then
        sc_repl_debug " - skip pattern matched: ${skip_pattern}"
        sc_repl_debug "sc_repl_verify_or_unbind() ... done"
        return
    fi
    
    opts=("--shell=bash" "--external-sources")
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
    style=${SHELLCHECK_REPL_INFO:-""}
    style=${style,,}
    if [[ -z "${style}" ]]; then style="clean"; fi
    sc_repl_debug " - style: ${style}"
    sc_repl_debug " - ShellCheck options: ${opts[*]}"
    sc_repl_debug " - READLINE_LINE: ${READLINE_LINE}"

    ## Identify variables to be included in preamble
    vars=()
    if [[ ! "$SHELLCHECK_REPL_EXCLUDE" == *2154* ]]; then
        sc_repl_debug " - Special case: Checking with rule SC2154"
        ## Ask shellcheck to identify variables of interest
        mapfile -t vars < <(shellcheck --shell=bash --format=gcc --exclude="${SHELLCHECK_REPL_EXCLUDE}" <(echo "$READLINE_LINE") | grep -F "[SC2154]" | sed -E 's/.*warning: ([^ ]+) .*/\1/')
    fi

    if [[ ! "$SHELLCHECK_REPL_EXCLUDE" == *2178* ]]; then
        sc_repl_debug " - Special case: Checking with rule SC2178"
        ## Ask shellcheck to identify variables of interest
        mapfile -t tmp < <(shellcheck --shell=bash --format=gcc <(echo "$READLINE_LINE") | grep -F "[SC2034]" | sed -E 's/.*warning: ([^ ]+) .*/\1/')
        vars+=("${tmp[@]}")
    fi
    
    sc_repl_debug " - Variables: [n=${#vars[@]}] ${vars[*]}"
    
    ## Are there any variables involved?
    if [[ ${#vars[@]} -gt 0 ]]; then
        ## 'declare -p' dump only those
        input=$(declare -p "${vars[@]}" 2> /dev/null)
        input=$(printf "#dummy to disable does not apply to everything\ntrue\n#shellcheck disable=all\n{\ntrue\n%s\n}\n\n%s\n" "${input}" "$READLINE_LINE")
    else
        input=$READLINE_LINE
    fi
    

    sc_repl_debug " - ShellCheck input: $(echo "${input}" | wc -l) lines"
    start_time=$(date +%s%N)    
    case ${style} in
        raw-tty)
            shellcheck "${opts[@]}" --format=tty <(echo "${input}")
            ;;
        raw-gcc)
            shellcheck "${opts[@]}" --format=gcc <(echo "${input}")
            ;;
        full)
            shellcheck "${opts[@]}" <(echo "${input}") | tail -n +2
            ;;
        clean)
            shellcheck "${opts[@]}" <(echo "${input}") | sed -n '1,2b; /^$/q; p'
            ;;
        note)
            shellcheck "${opts[@]}" --format=gcc <(echo "${input}") | cut -d : -f 4- ;;
        *)
            sc_repl_error "Unknown value for shellcheck-repl variable 'SHELLCHECK_REPL_INFO' (valid values are 'raw', 'full', 'short' and 'clean' [default]): '${SHELLCHECK_REPL_INFO}'"
            ;;
    esac
    
    if [[ "${PIPESTATUS[0]}" != 0 ]]; then
        if ${SHELLCHECK_REPL_VERBOSE}; then
            >&2 echo
            >&2 echo "To skip a check, add its SC number to 'SHELLCHECK_REPL_EXCLUDE', e.g."
            >&2 echo
            >&2 echo "  export SHELLCHECK_REPL_EXCLUDE=\"\${SHELLCHECK_REPL_EXCLUDE},4038\""
            >&2 echo
            >&2 echo "Currently, SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE}"
            >&2 echo
            >&2 echo "To skip ShellCheck validation for this call, append two spaces"
            >&2 echo
        fi

        sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b1"

        ## Avoid Bash 5.1.* bug
        bind -r "\C-x\C-b2"
        sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b1"

        ## Key sequence: {Ctrl-x Ctrl-b 2}
        ## Executes shell command: sc_repl_verify_bind_accept
        bind -x '"\C-x\C-b2": sc_repl_verify_bind_accept'
        sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b2"
        sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b1"
    fi

    end_time=$(date +%s%N)
    
    sc_repl_debug " - check time: $(((end_time - start_time) / 1000000)) ms"

    sc_repl_debug "sc_repl_verify_or_unbind() ... done"
}

sc_repl_verify_bind_accept() {
    sc_repl_debug "sc_repl_verify_bind_accept() ..."
    ## Avoid Bash 5.1.* bug
    bind -r "\C-x\C-b2"
    
    ## Key sequence: {Ctrl-x Ctrl-b 2}
    ## Executes function: accept-line
    bind '"\C-x\C-b2": accept-line'
    sc_repl_assert_function_keybinding_exists "\C-x\C-b2"
    sc_repl_debug "sc_repl_verify_bind_accept() ... done"
}

sc_repl_enable() {
    sc_repl_debug "sc_repl_enable() ..."

    sc_repl_verify_bind_accept

    ## Avoid Bash 5.1.* bug
    bind -r "\C-x\C-b1"
    bind -r "\C-m"

    ## Key sequence: {Ctrl-x Ctrl-b 1}
    ## Executes shell command: sc_repl_verify_or_unbind()
    bind -x '"\C-x\C-b1": sc_repl_verify_or_unbind'
    sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b1"
    
    ## Key sequence: Ctrl-m (Carriage Return)
    ## Executes keystrokes: {Ctrl-x Ctrl-b 1} {Ctrl-x Ctrl-b 2}
    bind '"\C-m": "\C-x\C-b1\C-x\C-b2"'
    sc_repl_assert_sequence_keybinding_exists "\C-m"
    sc_repl_assert_shell_command_keybinding_exists "\C-x\C-b1"
    sc_repl_debug "sc_repl_enable() ... done"
}

sc_repl_disable() {
    sc_repl_debug "sc_repl_disable() ..."
    bind -r "\C-m"
    
    ## Key sequence: Ctrl-m (Carriage Return)
    ## Executes function: accept-line
    bind '"\C-m": accept-line'
    sc_repl_assert_function_keybinding_exists "\C-m"
    sc_repl_debug "sc_repl_disable() ... done"
}

sc_repl_init() {
    local defaults
    
    sc_repl_debug "sc_repl_init() ..."
    sc_version
    if ! sc_repl_asserts; then
        sc_repl_error "ShellCheck REPL startup assertions failed"
        return 1
    fi

    ## Ignore some ShellCheck issues:
    ## SC1001: This \= will be a regular '=' in this context.
    ## SC1044: Couldn't find end token `EOF' in the here document.
    ## SC1090: Can't follow non-constant source. Use a directive to specify
    ##         location.
    ## SC1091: Not following: (error message here).
    ## SC1113: Use #!, not just #, for the shebang.    
    ## SC2034: 'var' appears unused. Verify it or export it.
    ## SC2096: On most OS, shebangs can only specify a single parameter.
    ## SC2155: Declare and assign separately to avoid masking return values.
    ## SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    defaults=1001,1044,1090,1091,1113,2034,2096,2155,2164
    sc_repl_debug "- defaults: ${defaults}"
    SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE:-${defaults}}
    sc_repl_debug "- SHELLCHECK_REPL_EXCLUDE: ${SHELLCHECK_REPL_EXCLUDE}"
    sc_repl_enable
    sc_repl_debug "sc_repl_init() ... done"
}

sc_wiki_url() {
    echo "https://github.com/koalaman/shellcheck/wiki/$1"
}


## Deprecation warning
if [[ -n ${SHELLCHECK_REPL_INIT} ]]; then
    sc_repl_error "SHELLCHECK_REPL_INIT is defunct. Use SHELLCHECK_REPL_ACTION=init or SHELLCHECK_REPL_ACTION=none instead"
fi

case ${SHELLCHECK_REPL_ACTION:-"enable"} in
    disable)
        sc_repl_disable "";;
    enable)
        sc_repl_init "";;
    sessioninfo)
        sc_repl_sessioninfo;;
    *)
        sc_repl_error "Unknown value on SHELLCHECK_REPL_ACTION: '${SHELLCHECK_REPL_ACTION}'"
esac
