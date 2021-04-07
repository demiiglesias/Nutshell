%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <stdbool.h>

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

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS SETENV UNSETENV PRINTENV UNALIAS END

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| SETENV STRING STRING END 		{RunSetEnv($2, $3); return 1;}
	| PRINTENV END           		{RunPrintEnv(); return 1;}
	| UNSETENV STRING END			{RunUnsetEnv($2); return 1;}
	| ALIAS END						{RunPrintAlias(); return 1;}
	| UNALIAS STRING END 			{RunUnalias($2); return 1;}
	
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
	return 1;}

bool checkAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if((strcmp(aliasTable.name[i], name)) == 0) {
            printf("Error not in table ");
			return true;
        } 
    }
	return false;
}

//does this account for the infinite loop?
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

int RunPrintAlias(){
for (int i = 0; i < aliasIndex; i++){
		printf("%s = ", aliasTable.name[i]);
		printf("%s\n",aliasTable.word[i]);
	}
	printf("alias index: %d", aliasIndex);
	//return 1;
}
//name=word
//name is the alias
int RunUnalias(char* name){
	printf("%s", name);
	int index;
	if (checkAlias(name) != true){
		for(int i = 0; i < aliasIndex; i++){
			if (strcmp(aliasTable.name[i], name) == 0) {
			index = i;
			strcpy(aliasTable.name[i], "");
			strcpy(aliasTable.word[i], "");
			}
		}
		for(int j = index + 1; j < aliasIndex; j++){
			printf("alias index: %d", aliasIndex);
			printf("index in loop: %d", index);
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

//setenv hunter demi
//unsetenv hunter, hunter is the variable
//unsetenv demi, should not work because demi is the word