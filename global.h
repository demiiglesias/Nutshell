struct evTable {
   char var[128][100];
   char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};

struct evTable varTable;
struct aTable aliasTable;

int aliasIndex, varIndex;
char* subAliases(char* name);