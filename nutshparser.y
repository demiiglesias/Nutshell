%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <stdbool.h>

int yylex();
int yyerror(char *s);
int runCD(char* arg);
int runSetAlias(char *name, char *word);
int RunSetEnv(char* var, char* word);
int RunPrintEnv();
int RunUnsetEnv(char* word);
bool checkEnv(char* word);

%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS SETENV UNSETENV PRINTENV END

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| SETENV STRING STRING END 		{RunSetEnv($2, $3); return 1;}
	| PRINTENV END           		{RunPrintEnv(); return 1;}
	| UNSETENV STRING END			{RunUnsetEnv($2); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }
// one function for defaults, one with one argument, one with two arguments
int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			strcpy(aliasTable.word[0], varTable.word[0]);
			strcpy(aliasTable.word[1], varTable.word[0]);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
				*pointer ='\0';
				pointer++;
			}
		}
		else {
			//strcpy(varTable.word[0], varTable.word[0]); // fix
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(aliasTable.word[0], arg);
			strcpy(aliasTable.word[1], arg);
			strcpy(varTable.word[0], arg);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
			*pointer ='\0';
			pointer++;
			}
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
	return 1;
}

int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
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

bool checkEnv(char* word){
    for(int i = 0; i < varIndex; i++ ){
        if((strcmp(varTable.word[i], word)) == true){
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
		printf("enter")
		printf("%s =", varTable.word[i]);
		printf("Hello")
		//printf("\n");
		printf("%s\n",varTable.var[i]);
	}
	return 1;
}

int RunUnsetEnv (char* word) {
// check for the data, replace with empty string
// break out and have another loop to push everything by one
// start from i+1, put 9 in the place of 8, etc
int index;
	if (checkEnv(word) == true){
		for(int i = 0; i < varIndex; i++){
			if(strcmp(varTable.word[i], word) == 0) {
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
		printf("ppppp");
		printf("Word: %d does not exist\n", *word);
		printf("hekko");
		return 1;		
	}
}

