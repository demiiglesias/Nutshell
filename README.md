# Nutshell
A command interpreter for a Korn shell-like command language in C using Lex and Yacc running under Unix, written by Hunter Becker and Demi Iglesias.
Our code is contained withing the global.h, nutshscanner.l, nutshparser.y, nutshell.c.

## Missing Features
* Redirecting I/O with Non-built-in Commands
* Using Pipes with Non-built-in Commands
* Running Non-built-in Commands in Background
* Using both Pipes and I/O Redirection, combined, with Non-built-in Commands
* Wildcard Matching

## Working Features
* All Built- in commands (alias, unalias, setenv, unsetenv, printenv, cd)
* Non-built-in Commands  (s, pwd, wc, sort, page, nm, cat, cp, mv, ping, echo, etc., with and without arguments)
* Environment Variable Expansion (doesn't work in some instances)
* Alias Expansion
* Shell Robustness (does not crash)





