// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <limits.h>
char *getcwd(char *buf, size_t size);

int main()
{
    aliasIndex = 0;
    varIndex = 0;
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    strcpy(aliasTable.name[aliasIndex], ".");
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    char *pointer = strrchr(cwd, '/');
    while(*pointer != '\0') {
        *pointer ='\0';
        pointer++;
    }
    strcpy(aliasTable.name[aliasIndex], "..");
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    system("clear");
    while(1)
    {
        printf("[%s]>> ", varTable.word[2]);
        yyparse();
    }

    return 0;
}