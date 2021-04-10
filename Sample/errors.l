%{
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"
#include <errno.h>
#include <iostream>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

extern int errno;
int wordcount = 0;

//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
//complete
bool ifWhitespace(char* input) {
for (int i = 0; i < strlen(input); i++) {
     if (input[i] == '\t' || input[i] == ' '){
         return true;
        }
        return false;
    } 
}
//complete
char* concatStr(char* str1, char* str2) {
    char* result = malloc(strlen(str1)+strlen(str2)+1);
    strcpy(result, str1);
    strcat(result, str2);
    return result;
}
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
bool ifPath(char* argStr){
    char* strnew;
    char* arg[2];
    arg[0] = "/bin/";
    if(ifWhitespace(argStr)){
        strnew = strtok(argStr, " /t");
    }
    else{
        strnew = argStr;
    } 
    arg[1] = strnew;
    char* cstr = concatStr(arg[0], arg[1]);
    int fd = access(cstr, F_OK);
    if(fd == -1){
        printf("Error Number : %d\n", errno);
        perror("Error Description:");
        return false;
    }
    else{
        printf("No error\n");
        strcpy(argTable.argList[0], cstr);
        return true;
    }


%array
%option noyywrap

CHAR               [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%x string_condition
%%

<string_condition>{ANYCHAR}+     {yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);}

[ ]		            { }
bye                 { wordcount = 1; return BYE; }
crd		            { wordcount = 1; return CD;}
alias		        { wordcount = 1; return ALIAS; }
setenv              { wordcount = 1; return SETENV;}
printenv            { wordcount = 1; return PRINTENV;}
unsetenv            { wordcount = 1; return UNSETENV;}
unalias             { wordcount = 1; return UNALIAS;}
cmd                 { wordcount = 1; return CMD;}
"\n"		        { wordcount = 0, argIndex = 0; return END;}
[\"]                { BEGIN(string_condition); }
{CHAR}+             {
                        if(ifAlias(yytext) && wordcount == 0) {
                           char *yycopy = strdup(subAliases(yytext));
                                for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
                                    unput(yycopy[i]);
                                printf("yycopy after sub: %s\n", yycopy);
                                free(yycopy);
                        }
                        if(ifPath(yytext)){
                            if(ifArguments(yytext)){
                            return CMD;
                            }
                            else {
                                return CMD;
                            }
                        } 
                        else {
                            yylval.string = strdup(yytext);
                             wordcount++;   
                             return STRING;
                        };
                     }
%%
//search the bin for the command to determine whether it exists
        // if there is white space
        // then tokenize the contents of it to the first token
        // take that token, traverse bin for that token
        // if said token exists in bin, return true
        // if said token does not exist in bin, return false