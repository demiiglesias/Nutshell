
%{
#include <stdio.h>

int yylex();
int yyerror(char *s);

%}

%token STRING NUM TAB BLANK OTHER SEMICOLON /*declares token usage/ accepted tokens*/

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

stmts:
		| stmt SEMICOLON stmts

stmt:
		STRING {
				printf("You entered a string - %s", $1);
		}
		| NUM {
				printf("The number you entered is - %d", $1);
		} 
		| TAB {
				printf("\nNo. of tabs=%d", tc);
		} 
		| BLANK {
				printf("\nNo. of spaces=%d", sc);
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