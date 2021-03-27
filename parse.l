%{

#include <stdio.h>
#include <string.h>
#include "parse.tab.h"
void showError();
%}

/****regular expressions*****/
numbers     ([0-9])+
alpha       ([a-zA-Z])+

/****token specifications*****/
%%

{alpha}			   {sscanf(yytext, "%s", yylval.name); return (STRING);}
{numbers}          {yylval.number = atoi(yytext); return (NUM);}
";"      		   {return (SEMICOLON);}
.      		       {showError(); return(OTHER);} /*. captures everything not accounted for*/

%%

/* C functions (can be main or others) */
void showError(){
    printf("Other input");
}