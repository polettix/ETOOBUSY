#!/bin/sh

commands() { #<command>
#<help> usage: commands
#<help> print a list of available commands.
	{
   	printf '%s available (sub-)commands:\n' "$0"
      sed -ne '/#<command> *$/s/\([a-zA-Z0-9_]*\).*/- \1/p' "$0"
		printf 'Run the help command for help on each of the commands above\n'
   } >&2
}

help() { #<command>
#<help> usage: help
#<help> print help for all available commands
    {
        printf '\nUsage: %s <command> [<arg> [...]]\n\nAvailable (sub-)commands:\n' "$0"
        sed -ne '
            /#<command> *$/s/\([a-zA-Z0-9_]*\).*/\n- \1/p
            s/^#<help> /    /p
            s/^#<help>//p
        ' "$0"
    } >&2
}

foo() { #<command>
#<help> usage: foo <frob> [<taz> [...]]
#<help> apply the foo function to frob, optionally taking into account one
#<help> or more taz-es.
    local frob="$1"
    shift
    printf '%s\n' "foo($frob) with <$*>"
}

# This comment is ignored by the help function
bar() { #<command>
#<help> usage: bar <n> <m>
#<help> compute bar on n and m and print the result out.

    local n="$1"
    local m="$2"
    printf '%s\n' "$((n + m))"
}

main() {
   [ $# -gt 0 ] || set -- commands
   "$@"
}

! grep -- 'yadda-20200320-example-sh' "$0" >/dev/null 2>&1 \
   || main "$@"

# distance a bit from the prompt
#<help>
