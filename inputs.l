%{
#include <stdio.h>
#include <string.h>
#include "inputs.tab.h"
void showError();
%}

/* We want to add < > | " \ & */
/* regular expressions */
numbers     ([0-9])+
alpha       ([a-zA-Z])+ 
whitespace  ([ \t\n])
operations  ([. .. < > \ & | ]) 

/*  tokens Spec.  */
%%

{alpha}			   {sscanf(yytext, "%s", yylval.name); return (STRING);}
{numbers}          {yylval.number = atoi(yytext); return (NUM);}
{whitespace}       ;


.      		       {showError(); return(OTHER);} 

%%

/* C functions (can be main or others) */
void showError(){
    printf("Other input");
}