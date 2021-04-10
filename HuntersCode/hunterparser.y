%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <pwd.h>
#include <glob.h>
#include <stdbool.h>
#include <dirent.h>
#include "global.h"

int yylex();
int yyerror(char* s);
int runCD(char* arg);
int runSetAlias(char* name, char* word);
int RunSetEnv(char* var, char* word);
int RunPrintEnv();
int RunUnsetEnv(char* var);
int RunUnalias(char* name);
int RunPrintAlias();
bool checkEnv(char* var);
bool checkAlias(char* name);

%}