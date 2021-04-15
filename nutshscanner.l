%{
#include "nutshparser.tab.h"
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
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

bool varExist(char* var){
    for(int i = 0; i < varIndex; i++){
        if (strcmp(varTable.var[i],var) == 0){
            //printf("enter 3");
            return true;
        }
    }
    return false;
}
char* varSub(char* var){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return varTable.word[i];
        }
    }
    return var;
}
//tokenize and concat
void envExpan(char* input, char* final){
    char s2[] = "${";
    char s1[] = "}";
    int envNum = 0; //number of env to replace
	char string[100];
    char  envVars[128][100];
	char* token;
	strcpy(string, input);
	    printf("Input from rule: %s\n", string);
    if(strstr(string, s2)){
        token = malloc(sizeof(string));
        token = strtok(string, "${}");
        strcpy(envVars[envNum], token);
        //envNum++;
            while (token != NULL) //splits up the env vars
            {
            strcpy(envVars[envNum], token);
            printf("env Vars: %s\n",envVars[envNum]);
            envNum++;
            token = strtok(NULL, "${}");
            }
        printf("envNum: %d\n", envNum);
        for (int i = 0; i < envNum; i++) {
            if (varExist(envVars[i])){
                printf("env Vars subbed: %s, ",envVars[i]);
                printf("string length: %d, ",strlen(envVars[i]));
                strcpy(envVars[i], varSub(envVars[i]));
                printf("env Vars subbed with: %s\n",envVars[i]);
            }
        }
        char temp[100];
        memset(temp, 0, sizeof(temp));
        printf("Temp string: %s\n", temp);
        
        for (int i = 0; i < envNum; i++) {
        strcpy(temp, strcat(temp, envVars[i])) ;
        }
        printf("Returned string: %s\n", temp);
        strcpy(final, temp);
        return;
        }
        else{
        printf("Returned string: %s\n", input);
        strcpy(final, input);
        return;
    } 
    
}

%}
%array
%option noyywrap

CHAR            [.A-Za-z0-9!\?*/~|:_-][.A-Za-z0-9!\?*/~|:_-]*
ANYCHAR         [)(*&%$#@}{!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@}{!`;,\.a-zA-Z0-9'/*_=~ -]*

%x string_condition 
%x envexpan
%x wildcard
%x pipe
%%

<string_condition>{ANYCHAR}+    {char final[100];
                                 char *yycopy;
                                 envExpan(yytext, final); 
                                 yylval.string = strdup(final); 
                                 return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}
<envexpan>{CHAR}+               {if(varExist(yytext) && wordcount == 0) {
                                    printf("Current value from stream: %s\n", yylval.string);
                                    char *yycopy = strdup(varSub(yytext));
                                    for (int i = strlen(varSub(yytext)) - 1; i >= 0; --i)
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
<envexpan>[\}]                 {BEGIN(INITIAL);}

                       
[ ]		            { wordcount = 0;}
bye                 { wordcount = 1; return BYE;}
cd		            { wordcount = 1; return CD;}
alias		        { wordcount = 1; return ALIAS;}
setenv              { wordcount = 1; return SETENV;}
printenv            { wordcount = 1; return PRINTENV;}
unsetenv            { wordcount = 1; return UNSETENV;}
unalias             { wordcount = 1; return UNALIAS;}    
"\n"		        { wordcount = 0; return END;}
"\^\["              { printf("we did it"); return END;}
[\"]                { BEGIN(string_condition);}
"$"\{               { BEGIN(envexpan);}

{CHAR}+             {if(ifAlias(yytext) && wordcount == 0) {
                           char *yycopy = strdup(subAliases(yytext));
                                for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
                                    unput(yycopy[i]);
                                printf("yycopy after sub: %s\n", yycopy);
                                free(yycopy);
                        }
                        else {
                            int i = 0;
                            char *yycopy = strdup(yytext);
                            yylval.string = strdup(yytext);
                            wordcount++;   
                            return STRING;  
                        };
                    }
%%

// while (yycopy[i] != '\0') {    /* Stop looping when we reach the null-character. */
// printf("%c\n", yycopy[i]);    /* Print each character of the string. */
// i++;
// }