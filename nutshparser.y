%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <stdbool.h>
#include <dirent.h>
#include <errno.h>
extern int errno;
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
int RunBinCommands();
char* concatStr(char* str1, char* str2);
bool ifWhitespace(char* input);
int RunPathSplitter();
//double $$ symbol for value of group
%}

%union {
	char *string;
}

%start cmd_line
%token <string> BYE CD STRING ALIAS SETENV UNSETENV PRINTENV UNALIAS CMD PRINTARG END

%%
cmd_line:
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| SETENV STRING STRING END 		{RunSetEnv($2, $3); return 1;}
	| PRINTENV END           		{RunPrintEnv(); return 1;}
	| UNSETENV STRING END			{RunUnsetEnv($2); return 1;}
	| ALIAS END						{RunPrintAlias(); return 1;}
	| UNALIAS STRING END 			{RunUnalias($2); return 1;}
	| arg_list END					{RunPathSplitter(); RunBinCommands(); return 1;}
;
arg_list:
	STRING							{strcpy(cmdTable.cmds[cmdIndex], $1);
									cmdTable.argument[cmdIndex].argCount++;}
	
	| arg_list STRING				{strcpy(cmdTable.argument[cmdIndex].args[argIndex], $2);
									argIndex++;}
;
%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }

//complete
char* concatStr(char* str1, char* str2) {
    char* result = malloc(strlen(str1)+strlen(str2)+1);
    strcpy(result, str1);
    strcat(result, str2);
    return result;
}
int RunPathSplitter(){
//loop through varTable.var[3] until there are no delimiters
//take the delimiters, place them into pTable.paths[pathIndex]
	pathIndex = 0;
	char string[100];
	char* token;
	strcpy(string, varTable.word[3]);
	//printf("%s\n", string);
	token = malloc(sizeof(string));
	token = strtok(string, ":");
	token = strtok(NULL, ":"); //this may need to be fixed depending on what they change the path to ".:"
	//strcpy(pTable.paths[count], token);
	//count++;
  		while (token != NULL)
  		{
		strcpy(pTable.paths[pathIndex], token);
		//printf("%s\n",pTable.paths[pathIndex]);
		pathIndex++;
		token = strtok(NULL, ":");
  		}
	return 1;
}
//env table
// PWD = /mnt/e/Git/Nutshell/Nuts//.. (errors) [0]
// HOME = /mnt/e/Git/Nutshell (doesn't change) [1]
// one function for defaults, one with one argument, one with two arguments
int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

bool checkAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if((strcmp(aliasTable.name[i], name)) == 0) {
            //printf("Error not in table ");
			return true;
        } 
    }
	return false;
}

//does this account for the infinite loop?
// a = name , b = word
// a == b 
// b != a
int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){ 
			printf("Error1, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error2, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(!(strcmp(aliasTable.name[i], name) == 0) && !(strcmp(aliasTable.word[i], word) == 0)){
			for (int j = 0; j < aliasIndex; j++){
				if((strcmp(aliasTable.name[j], word) == 0) && (strcmp(aliasTable.word[j], name) == 0)){
					printf("Error3, expansion of \"%s\" would create a loop.\n", name);
					return 1;
				}
			}
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;
	return 1;
}

int RunPrintAlias(){
for (int i = 0; i < aliasIndex; i++){
		printf("%s = ", aliasTable.name[i]);
		printf("%s\n",aliasTable.word[i]);
	}
	printf("alias index: %d\n", aliasIndex);
	//return 1;
}
//name=word
//name is the alias
int RunUnalias(char* name){
	printf("name: %s\n", name);
	int index;
	if (checkAlias(name) == true){
		for(int i = 0; i < aliasIndex; i++){
			if (strcmp(aliasTable.name[i], name) == 0) {
			index = i;
			strcpy(aliasTable.name[i], "");
			strcpy(aliasTable.word[i], "");
			}
		}
		for(int j = index + 1; j < aliasIndex; j++){
			strcpy(aliasTable.name[index], aliasTable.name[j]);
			strcpy(aliasTable.name[j], "");
			strcpy(aliasTable.word[index], aliasTable.word[j]);
			strcpy(aliasTable.word[j], "");
			index++;
		}
		aliasIndex--;
		return 1;
	}
	else {
		printf("Alias: %s does not exist\n", name);
		return 1;		
	}
}

bool checkEnv(char* var){
    for(int i = 0; i < varIndex; i++ ){
        if((strcmp(varTable.var[i], var)) == 0){
            return true;
        }
    }
    return false;
}

int RunSetEnv (char* var, char* word){
	for (int i = 0; i < varIndex; i++) {
		if(strcmp(varTable.var[i], var) == 0) {
			strcpy(varTable.word[i], word);
			return 1;
		}
	}
		strcpy(varTable.var[varIndex], var);
		strcpy(varTable.word[varIndex], word);
		varIndex++;

		return 1;
}

int RunPrintEnv() {
	for (int i = 0; i < varIndex; i++){
		printf("%s=", varTable.var[i]);
		printf("%s\n",varTable.word[i]);
	}
	return 1;
}

int RunUnsetEnv (char* var) {
// check for the data, replace with empty string
// break out and have another loop to push everything by one
// start from i+1, put 9 in the place of 8, etc
	if(strcmp(varTable.var[1], var) == 0 || strcmp(varTable.var[3], var ) == 0|| strcmp(varTable.var[2], var) == 0 || strcmp(varTable.var[0], var) == 0){
		printf("Error: User cannot unsetenv %s\n", var);
				return 1;
	}
	int index;
	if (checkEnv(var) == true){
		for(int i = 0; i < varIndex; i++){
			if(strcmp(varTable.var[i], var) == 0) {
			index = i;
			strcpy(varTable.word[i], "");
			strcpy(varTable.var[i], "");
			}
		}
		for(int j = index + 1; j < varIndex ; j++){
			strcpy(varTable.word[index], varTable.word[j]);
			strcpy(varTable.word[j], "");
			strcpy(varTable.var[index], varTable.var[j]);
			strcpy(varTable.var[j], "");
			index++;
		}
		varIndex--;
		return 1;
	}
	else {
		printf("Variable: %s does not exist\n", var);
		return 1;	
	}	
}

bool ifWhitespace(char* input) {
for (int i = 0; i < strlen(input); i++) {
     if (input[i] == '\t' || input[i] == ' '){
         return true;
        }
        return false;
    } 
}

// runs command
int RunBinCommands(){
	int check;
	int count;
	char* argPass[argIndex+2];
	char* fpath;
	//printf("reached");
	for (int i = 0; i < pathIndex; i++){ //get all paths
    char* path[2];
	char* temp = strcat(pTable.paths[i], "/");
	//printf("Temp path: %s\n", temp);
    path[0] = temp;
    path[1] = cmdTable.cmds[cmdIndex];
    char* npath = concatStr(path[0], path[1]);
	//printf("npath path: %s\n", npath);
    int fd = access(npath, F_OK);
    if(fd == -1 && i+1 == pathIndex){ //iterated through all, no directory exists
		printf("Error Number: %d\n", errno);
        perror("Error Description");
        return 0;
	}
	else if(fd == -1){ //directory does not have command
		continue;
    }
    else { //command does exist
        //printf("%s\n", npath);
		fpath = npath;
		argPass[0] = npath;
		for (int i = 1; i <= argIndex; i++){
		argPass[i] = cmdTable.argument[cmdIndex].args[i-1];
		}
		argPass[argIndex+1] = NULL;
		
    }
	}
	if (fork() == 0 ) {
		for (int i = 0; i <= argIndex; i++){
		//printf("%s\n", argPass[i]);
		}
		//printf("%d\n", argIndex);
		execve(fpath, argPass, NULL);
	}
	else{
		wait(&check);
		}
	argIndex = 0;
    return 1;
}