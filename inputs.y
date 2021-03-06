
%{
#include <stdio.h>

int yylex();
int yyerror(char *s);

%}

%token STRING NUM WHITESPACE OTHER 

%type <name> STRING /*token has this type of data type*/
%type <number> NUM

%union{
	char name[20];
    int number;
}
/* program start, want to use "prog:"" in general */
%%

prog: 
  stmts
;
expr:
	expr "'\'" expr;
	|expr '<' expr;
	|expr '>' expr;
	|expr '&' expr;
;

stmts:
		| stmt expr stmts

stmt:
		STRING {
				printf("You entered a string - %s", $1);
		}
		| NUM {
				printf("The number you entered is - %d", $1);
		} 
		| OTHER
;

%%

int yyerror(char *s)
{
	printf("Syntax Error on line %s\n", s);
	return 0;
}

int main()
{
    yyparse(); /*important for the compiler and the directives using bison libraries*/
    return 0;
}