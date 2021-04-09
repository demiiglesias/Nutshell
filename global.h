struct evTable {
   char var[128][100];
   char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};
struct argumentTable {
   char* argString;
   char argList[128][100];
}
struct evTable varTable;
struct aTable aliasTable;
struct argumentTable argTable;

int aliasIndex, varIndex, argIndex;
char* subAliases(char* name);