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
    echo "0.1.4-9003"
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

SC_REPL_DEBUG=${SC_REPL_DEBUG:-false}

sc_repl_debug() {
    $SC_REPL_DEBUG || return 0
    echo >&2 "DEBUG: ${*}"
}

sc_repl_debug_keybindings() {
    $SC_REPL_DEBUG || return 0
    sc_repl_debug "All active keybindings per 'bind -X':"
    { bind -X 1>&2; } > /dev/null
}

sc_repl_error() {
    echo >&2 "ERROR: ${*} [shellcheck-repl $(sc_repl_version)]"
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

sc_repl_assert_keybind_exists() {
    sc_repl_debug "sc_repl_assert_keybind_exists('${1}') ..."
    ## Skip tests if 'bind -X' is not supported
    if ! sc_repl_bind_has_option_X; then
        sc_repl_debug "sc_repl_assert_keybind_exists('${1}') ... SKIP"
	return 0
    fi

    if ! bind -X | grep -q -F '"'"${1:?}"'":'; then
        sc_repl_debug_keybindings
	sc_repl_error "No such keybinding: ${1}"
        sc_repl_debug "sc_repl_assert_keybind_exists('${1}') ... ERROR"
	return 1
    fi
    sc_repl_debug "sc_repl_assert_keybind_exists('${1}') ... OK"
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
    local res
    
    sc_repl_debug "sc_repl_verify_or_unbind() ..."
    
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
    style=${SHELLCHECK_REPL_INFO,,}
    sc_repl_debug " - style: ${style}"
    sc_repl_debug " - ShellCheck options: ${opts[*]}"
    sc_repl_debug " - READLINE_LINE: ${READLINE_LINE}"

    if [[ ! "$SHELLCHECK_REPL_EXCLUDE" == *2154* ]]; then
        sc_repl_debug " - Special case: SC2154 are not disabled"
        ## Version 1:
        # input=$(declare -p)
        # input=$(printf "#dummy to disable does not apply to everything\ntrue\n#shellcheck disable=all\n{\n%s\n}\n\n%s\n" "${input}" "$READLINE_LINE")
        
        ## Version 2: (only slightly faster)
        ## Prune 'declare -p' output to speedup shellcheck
        # input=$(declare -p | sed -E 's/^declare -([-irx]+) ([^=*]+)="(.*)"/declare -\1 \2=""/g' | sed -E 's/^declare -([aA]+) ([^=*]+)=[(](.*)[)]/declare -\1 \2=()/g')        
        # input=$(printf "#dummy to disable does not apply to everything\ntrue\n#shellcheck disable=all\n{\n%s\n}\n\n%s\n" "${input}" "$READLINE_LINE")

        ## Version 3: (much faster; almost as faster with disable=SC2154)
        ## Ask shellcheck to identify variables of interest
        mapfile -t vars < <(shellcheck --shell=bash --format=gcc --exclude="${SHELLCHECK_REPL_EXCLUDE}" <(echo "$READLINE_LINE") | grep -F "[SC2154]" | sed -E 's/.*: ([^ ]+) .*/\1/')
        if [[ ${#vars[@]} -gt 0 ]]; then
            ## 'declare -p' dump only those
            input=$(declare -p "${vars[@]}" 2> /dev/null)
            input=$(printf "#dummy to disable does not apply to everything\ntrue\n#shellcheck disable=all\n{\ntrue\n%s\n}\n\n%s\n" "${input}" "$READLINE_LINE")
        else
            input=$READLINE_LINE
        fi
    else
        input=$READLINE_LINE
    fi
    sc_repl_debug " - ShellCheck input: $(echo "${input}" | wc -l) lines"
    
    if [[ -z "${style}" ]]; then style="clean"; fi

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
    end_time=$(date +%s%N)
    
    if [[ "${PIPESTATUS[0]}" != 0 ]]; then
	>&2 echo
	>&2 echo "To skip a check, add its SC number to 'SHELLCHECK_REPL_EXCLUDE', e.g."
	>&2 echo
	>&2 echo "  export SHELLCHECK_REPL_EXCLUDE=\"\${SHELLCHECK_REPL_EXCLUDE},4038\""
	>&2 echo
	>&2 echo "Currently, SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE}"
	>&2 echo
	>&2 echo "To skip ShellCheck validation for this call, append two spaces"
	>&2 echo

        ## Execute shell command: sc_repl_verify_bind_accept
        ## Triggered by key sequence: Ctrl-x Ctrl-b 2
        bind -x '"\C-x\C-b2": sc_repl_verify_bind_accept'
        sc_repl_assert_keybind_exists "\C-x\C-b2"
    fi

    sc_repl_debug " - check time: $(((end_time - start_time) / 1000000)) ms"

    sc_repl_debug "sc_repl_verify_or_unbind() ... done"
}

sc_repl_verify_bind_accept() {
    sc_repl_debug "sc_repl_verify_bind_accept() ..."
    ## Execute shell command: accept-line
    ## Triggered by key sequence: Ctrl-x Ctrl-b 2
    bind '"\C-x\C-b2": accept-line'
    
    ## FIXME: Why does this assertion fail the _first_ time
    ## this function is called? /HB 2022-02-17
    sc_repl_assert_keybind_exists "\C-x\C-b2"
    
    sc_repl_debug "sc_repl_verify_bind_accept() ... done"
}

sc_repl_enable() {
    sc_repl_debug "sc_repl_enable() ..."

    ## FIXME: Ignore assertion error here (see above comment)
    sc_repl_verify_bind_accept 2> /dev/null

    ## Execute shell command: sc_repl_verify_or_unbind()
    ## Triggered by key sequence: Ctrl-x Ctrl-b 1
    bind -x '"\C-x\C-b1": sc_repl_verify_or_unbind'
    sc_repl_assert_keybind_exists "\C-x\C-b1"
    
    ## Execute keystrokes: Ctrl-x Ctrl-b 1 Ctrl-x Ctrl-b 2
    ## Triggered by key sequence: Ctrl-m (Carriage Return)
    bind '"\C-m": "\C-x\C-b1\C-x\C-b2"'
#    sc_repl_assert_keybind_exists "\C-m"
    sc_repl_debug "sc_repl_enable() ... done"
}

sc_repl_disable() {
    sc_repl_debug "sc_repl_disable() ..."
    ## Execute shell command: accept-line
    ## Triggered by key sequence: Ctrl-m (Carriage Return)
    bind '"\C-m": accept-line'
    sc_repl_assert_keybind_exists "\C-m"
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
    ## SC1090: Can't follow non-constant source. Use a directive to specify
    ##         location.
    ## SC2034: 'var' appears unused. Verify it or export it.
    ## SC2155: Declare and assign separately to avoid masking return values.
    ## SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    defaults=1001,1090,2034,2155,2164
    sc_repl_debug "- defaults: ${defaults}"
    SHELLCHECK_REPL_EXCLUDE=${SHELLCHECK_REPL_EXCLUDE:-${defaults}}
    sc_repl_debug "- SHELLCHECK_REPL_EXCLUDE: ${SHELLCHECK_REPL_EXCLUDE}"
    sc_repl_enable
    sc_repl_debug "sc_repl_init() ... done"
}

sc_wiki_url() {
    echo "https://github.com/koalaman/shellcheck/wiki/$1"
}

if ${SC_REPL_INIT:-true}; then
    sc_repl_init ""
fi

