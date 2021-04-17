# Nutshell
A command interpreter for a Korn shell-like command language in C using Lex and Yacc running under Unix, written by Hunter Becker and Demi Iglesias.

Our code is contained within the global.h, nutshscanner.l, nutshparser.y, nutshell.c. Use the makefile for easy compiling. 

## Missing Features
* Redirecting I/O with Non-built-in Commands
* Using both Pipes and I/O Redirection, combined, with Non-built-in Commands

## Working Features
* All Built- in commands (alias, unalias, setenv, unsetenv, printenv, cd)
* Running Non-built-in Commands in Background
* Non-built-in Commands  (s, pwd, wc, sort, page, nm, cat, cp, mv, ping, echo, etc., with and without arguments)
* Wildcard Matching
* Environment Variable Expansion (doesn't work in some instances)
* Alias Expansion
* Shell Robustness (does not crash)
* Tilde Expansion
* Pipes with Non-built-in Commands 

## Work Distribution
* Demi + Hunter: Using Pipes with Non-built-in Commands 
* Demi + Hunter: All Built- in commands (alias, unalias, setenv, unsetenv, printenv, cd)
* Hunter: Non-built-in Commands  (s, pwd, wc, sort, page, nm, cat, cp, mv, ping, echo, etc., with and without arguments)
* Hunter: Wildcard Matching
* Hunter: Environment Variable Expansion (doesn't work in some instances)
* Hunter: Alias Expansion 
* Demi + Hunter: Shell Robustness (does not crash)
* Demi + Hunter: Tilde Expansion

## Comments
Hunter - I was not aware that our HOME directory would need to be different depending on what user is using the Nutshell. For instance, if the fu or su command would be ran, it would change the HOME to the other user, depending on the input given. Our code sets HOME as an arbitrary path for the first user, as it doesn't necessarily say that it should be different anywhere in the spec or anywhere for that matter. 

Hunter - Using quotes with the environment variable expansion is rather tricky -- it works to change it to its correct variable, but unfortunately it sends the entirety of the string (whitespace included) from the lexer to the parser. It does not account for this (yet) and throws errors. Sorry.
