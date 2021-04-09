%{
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"
#include <stdbool.h>
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

//search the bin for the command to determine whether it exists
        // if there is white space
        // then tokenize the contents of it to the first token
        // take that token, traverse bin for that token
        // if said token exists in bin, return true
        // if said token does not exist in bin, return false
bool ifCommand(char * argStr){
    char* strnew;
    char* arg[2];
        arg[0] = "/bin/";
    if(ifWhitespace(argStr)){
        strnew = strtok (argStr, " /t");
    }
    else{
        strnew = argStr;
    } 
    arg[1] = strnew;
    char* cstr = concatStr(arg[0], arg[1]);
    //search the bin
    if(fork() == 0){
	    execve(args[0], cstr, NULL);
        return true;
    }
    return false;
}
//complete
char* concatStr(char* str1, char* str2) {
    char* result = malloc(strlen(str1)+strlen(str2)+1);
    strcpy(result, str1);
    strcat(result, str2);
    return result;
}
//if there exists arguments, place them in the argument table
//complete?
bool ifArguments(char * argStr){
    if(ifWhitespace(argStr)){
        argTable.argString = argStr;
        char* strnew;
        strnew = strtok (argStr, " /t");
        while (strnew != NULL) {
            printf ("%s\n",strnew);
            argTable.argList[argIndex] = strnew;
            argIndex++;
            strnew = strtok (NULL, " /t");
        }    
        return true;
    }
    return false;
}

//complete
bool ifWhitespace(char* input) {
for (i = 0; i < strlen(input); i++) {
     if (input[i] == '\t' || input[i] == ' '){
         return true;
}
    return false;
}

int only_whitespace(char* input)
{
    int i;
    for (i = 0; i < strlen(input); i++)
    {
        if (input[i] != '\t' && input[i] != ' ') return 0;
        argIndex
    }
    return 1;
}

%
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
                        if(ifCommand(yytext)){
                            //if command, check to see if there are any arguments
                            if(ifArguments(yytext)){
                            //if there exists arguments, place them in the argument table
                            
                            
                            
                            return CMD;
                            }
                            //if command, then we run the command (assuming no arguments)
                            else {return CMD;}
                            
                            
                            
                            //check if any of the arguments are keywords 
                        } 
                        else {
                            yylval.string = strdup(yytext);
                             wordcount++;   
                             return STRING;
                            
                        };
                     }
%%
// printf("yytext before sub: %s\n", yytext);
// printf("yytext: %s\n", yytext);
// 