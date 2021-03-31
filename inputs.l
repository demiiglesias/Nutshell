%{
#include <stdio.h>
#include <string.h>
#include "parse.tab.h"
void showError();
%}
/* We want to add < > | " \ & */
/****regular expressions*****/
numbers     ([0-9])+
alpha       ([a-zA-Z])+ 
tabs        (\t) tc++
space       ([]) sc++


/****token specifications*****/
%%

{alpha}			   {sscanf(yytext, "%s", yylval.name); return (STRING);}
{numbers}          {yylval.number = atoi(yytext); return (NUM);}
{tabs}             {return(TAB);}
{space}            {return (BLANK);}
";"      		   {return (SEMICOLON);}
.      		       {showError(); return(OTHER);} /*. captures everything not accounted for*/

%%

/* C functions (can be main or others) */
void showError(){
    printf("Other input");
}