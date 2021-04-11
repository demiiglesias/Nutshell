#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <pwd.h>
#include <glob.h>
#include <stdbool.h>
#include <dirent.h>
#include <limits.h>

struct evTable {
   char var[128][100];
   char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};
struct argumentTable {
   char args[128][100];
   int argCount;
};
struct pathTable {
   char paths[128][100];
};
struct commTable{
   char cmds[128][100];
   struct argumentTable argument[128];
};
char cwd[PATH_MAX];

struct pathTable pTable;
struct evTable varTable;
struct aTable aliasTable;
struct argumentTable argTable;
struct commTable cmdTable;

int aliasIndex, varIndex, cmdIndex, argIndex, pathIndex;
char* subAliases(char* name);