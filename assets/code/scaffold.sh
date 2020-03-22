#!/bin/sh

# You can put your stuff here at the beginning, and leave the rest where
# it is at the bottom. OR you can just "source" this as a library.





############################################################################
# Help system.
# See https://github.polettix.it/ETOOBUSY/2020/03/20/shell-script-help/
# Tag functions as "commands" by putting "#<command>" at the end of the sub
# declaration line, like this:
# Mark comments meant for help by starting them with '#<help>'
# See below for examples.

commands() { #<command>
#<help> usage: commands
#<help> print a list of available commands.
   {
   	printf '%s available (sub-)commands:\n' "$0"
      sed -ne '/#<command> *$/s/\([a-zA-Z0-9_]*\).*/- \1/p' "$0"
   } >&2
}

help() { #<command>
#<help> usage: help
#<help> print help for all available commands
   {
      printf '\nUsage: %s <command> [<arg> [...]]\n\n' "$0"
      printf 'Available (sub-)commands:\n'
      sed -ne '
         /#<command> *$/s/\([a-zA-Z0-9_]*\).*/\n- \1/p
         s/^#<help> /    /p
         s/^#<help>//p
      ' "$0"
   } >&2
}

############################################################################
# Various utilities to protect strings
# See https://github.polettix.it/ETOOBUSY/2020/03/22/shell-quoting-for-exec/
# See https://github.polettix.it/ETOOBUSY/2020/03/23/shell-dynamic-args/

array_freeze() { #<command>
#<help> usage: array_freeze [<arg> [<arg> [...]]]
#<help> freeze an argument array into a single string, printed on standard
#<help> output. When collected in $string, the argument array can be
#<help> restored with:
#<help>      exec "set -- $string"
   local i
   for i do
      printf '%s\n' "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/"
   done
   printf ' '
}

quote () { #<command>
#<help> usage: quote <string-to-quote-as-a-single-argument>
#<help> quote a string to be used in exec and its siblings (e.g. remote ssh)
   printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

############################################################################
# Logging functions
# See https://github.polettix.it/ETOOBUSY/2020/03/24/shell-logging-helpers/
_LOG() {
   : ${LOGLEVEL:='INFO'}
   LEVELS='
TRACE  TRACE DEBUG INFO WARN ERROR FATAL
DEBUG        DEBUG INFO WARN ERROR FATAL
INFO               INFO WARN ERROR FATAL
WARN                    WARN ERROR FATAL
ERROR                        ERROR FATAL
FATAL                              FATAL
   '
   local timestamp="$(date '+%Y-%m-%dT%H%M%S%z')"
   if printf '%s' "$LEVELS" \
         | grep "^$LOGLEVEL .* $1" >/dev/null 2>&1 ; then
      printf >&2 '[%s] [%5s] %s\n' "$timestamp" "$@"
   fi
}

set_LOGLEVEL() { #<command>
#<help> usage: set_LOGLEVEL <level>
#<help> set the LOGLEVEL variable to `level`, which acts as a threshold
#<help> for printing messages. Choose one of the available levels:
#<help> TRACE DEBUG INFO WARN ERROR FATAL
   LEVELS='
xTRACE
xDEBUG
xINFO
xWARN
xERROR
xFATAL
'
   if printf '%s' "$LEVELS" | grep "^x$1$" >/dev/null 2>&1 ; then
      LOGLEVEL="$1"
   else
      printf 'Invalid log level <%s>, using INFO instead\n' "$1"
      LOGLEVEL='INFO'
   fi
}

TRACE()  { _LOG TRACE "$*"; }    #<command>
#<help> usage: TRACE message
#<help> output a log message at TRACE level, if enabled

DEBUG()  { _LOG DEBUG "$*"; }    #<command>
#<help> usage: DEBG message
#<help> output a log message at DEBUG level, if enabled

INFO()   { _LOG INFO  "$*"; }    #<command>
#<help> usage: INFO message
#<help> output a log message at INFO level, if enabled

WARN()   { _LOG WARN  "$*"; }    #<command>
#<help> usage: WARN message
#<help> output a log message at WARN level, if enabled

ERROR()  { _LOG ERROR "$*"; }    #<command>
#<help> usage: ERROR message
#<help> output a log message at ERROR level, if enabled

FATAL()  { _LOG FATAL "$*"; }    #<command>
#<help> usage: FATAL message
#<help> output a log message at FATAL level, if enabled

LOGDIE() { FATAL "$*"; exit 1; } #<command>
#<help> usage: LOGDIE message
#<help> output a log message at FATAL level and exit with code 1


############################################################################
# Test functions.
# See: https://github.polettix.it/ETOOBUSY/2020/03/25/shell-variable-is_defined/
# See: https://github.polettix.it/ETOOBUSY/2020/03/26/shell-variable-is_true/
# See: https://github.polettix.it/ETOOBUSY/2020/03/27/shell-variable-is_lengthy/

is_var_defined () { eval "[ -n \"\${$1+ok}\" ]" ; } #<command>
#<help> usage: is_var_defined <variable-name>
#<help> test whether `variable-name` is defined (i.e. set) or not

is_var_true() { #<command>
#<help> usage: is_var_true <variable-name>
#<help> test whether `variable-name` holds a true value. An undefined variable
#<help> is false. Empty and 0 values are false. Everything else is true.
   local value
   eval 'value="${'"$1"':-"0"}"'
   [ "$value" != '0' ]
}

is_value_true() { #<command>
#<help> usage: is_value_true [<value>]
#<help> test whether `value` is true. An empty input list is false. If $1
#<help> is set, empty and 0 values are false. Everything else is true.
   [ $# -gt 0 ] || return 1    # empty input list -> false
   [ "${1:-"0"}" != '0' ]
}

is_var_lengthy() { #<command>
#<help> usage: is_var_lengthy <variable-name>
#<help> test whether <variable-name> is set and holds a non-empty value.
   local value
   eval 'value="${'"$1"':-""}"'
   [ -n "$value" ]
}
is_value_lengthy() { [ $# -gt 0 ] && [ -n "$1" ] ; } #<command>
#<help> usage: is_value_lengthy [<value>]
#<help> test whether the argument list is not empty and the first value
#<help> is not empty as well.


############################################################################
# Everything as a sub-command.
# See https://github.polettix.it/ETOOBUSY/2020/03/19/a-shell-approach/
# Hint: keep this at the bottom and change the string with something
# new/random for each new script.

#<help>
if grep -- 'change-this-with-whatevah-db049fa26dd59' "$0" >/dev/null 2>&1
then
   [ $# -gt 0 ] || set -- help
   "$@"
fi
