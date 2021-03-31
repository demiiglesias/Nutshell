// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
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