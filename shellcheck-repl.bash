# On 2019-03-28, GitHub user @xPMo wrote in response to https://github.com/koalaman/shellcheck/issues/1535:
#
# This overwrites the default enter (`\C-m`) binding to run `\C-x\C-b1\C-x\C-b2`.
# The reason for this method is that [bash widgets can do exactly one of: press keys, call external commands, or call readline commnads](https://stackoverflow.com/questions/8366450/complex-keybinding-in-bash). So, we press a bunch of keys, which we then bind to other commands.
# 
# `\C-x\C-b1` is bound to the checking function. If the check fails, it will rebind `\C-x\C-b2` to a function to bind it to `accept-line`.
# `\C-x\C-b2` is bound by default to accept-line (i.e.: run the command). When `shellcheck` succeeds, it will stay that way.
# I recommend adding a bind `'"\C-j": accept-line'` or similar so you can bypass the check if need be.
sc_verify_or_unbind(){
	shellcheck -S "${SC_VERIFY_LEVEL:=info}" -s bash -x \
		--exclude=2154 \
		<(printf '%s\n' "$READLINE_LINE") ||
		bind -x '"\C-x\C-b2": sc_verify_bind_accept'
}
sc_verify_bind_accept(){
	bind '"\C-x\C-b2": accept-line'
}
sc_verify_bind_accept
bind -x '"\C-x\C-b1": sc_verify_or_unbind'
bind '"\C-m":"\C-x\C-b1\C-x\C-b2"'
