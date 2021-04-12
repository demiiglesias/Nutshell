%{
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"
#include <errno.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
extern int errno;
int wordcount = 0;

//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}

// bool varFound(char * var){
//     for(int i = 0; i < varIndex; i++){
//         if (strcmp(varTable.var[i],var) == 0){
//             return true;
//         }
//     }
//     return false;
// }
// char* varReplace(char* var){
//     for(int i = 0; i < varIndex; i++){
//         return varTable.word[i];
//     }
//     return var;
// }

%}
%array
%option noyywrap

CHAR            [.A-Za-z0-9!\/:_-][.A-Za-z0-9!\/:_-]*
ANYCHAR         [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%x string_condition
%%

<string_condition>{ANYCHAR}+    {yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}
                       
[ ]		            { }
bye                 { wordcount = 1; return BYE;}
cd		            { wordcount = 1; return CD;}
alias		        { wordcount = 1; return ALIAS;}
setenv              { wordcount = 1; return SETENV;}
printenv            { wordcount = 1; return PRINTENV;}
unsetenv            { wordcount = 1; return UNSETENV;}
unalias             { wordcount = 1; return UNALIAS;}    
"\n"		        { wordcount = 0; return END;}
[\"]                { BEGIN(string_condition); }
{CHAR}+             {if(ifAlias(yytext) && wordcount == 0) {
                           char *yycopy = strdup(subAliases(yytext));
                                for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
                                    unput(yycopy[i]);
                                printf("yycopy after sub: %s\n", yycopy);
                                free(yycopy);
                        }
                        else {
                            yylval.string = strdup(yytext);
                             wordcount++;   
                             return STRING;
                        };
                    }
%%