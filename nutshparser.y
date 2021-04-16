%{
#include <stdio.h>
#include <fnmatch.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

#include <stdbool.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/wait.h>
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
bool ifCmdPath(char** argPass, int currentCommand);
int RunPathSplitter();
void RunWildCardExpan(char* arg);void RunPipes();
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
	| CD END						{runCD(varTable.word[1]); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| SETENV STRING STRING END 		{RunSetEnv($2, $3); return 1;}
	| PRINTENV END           		{RunPrintEnv(); return 1;}
	| UNSETENV STRING END			{RunUnsetEnv($2); return 1;}
	| ALIAS END						{RunPrintAlias(); return 1;}
	| UNALIAS STRING END 			{RunUnalias($2); return 1;}
	| arg_list END					{RunPathSplitter(); RunBinCommands(); return 1;}
;
arg_list:
	STRING							{strcpy(cmdTable.cmds[cmdIndex], $1);}
	
	| arg_list STRING				{if(strcmp($2, "|") == 0) {
									cmdIndex++;
									printf("commandindex- %d\n", cmdIndex);
									cmdCheck = 1; //the next STRING is a command
									}
									else if(strstr($2, "?") || strstr($2, "*")){
										//printf("caught");
										RunWildCardExpan($2);
									}	
									else if(cmdCheck == 1){
										strcpy(cmdTable.cmds[cmdIndex], $2);
										cmdCheck = 0; //the next STRING is an argument
									}
									else {
										strcpy(cmdTable.argument[cmdIndex].args[cmdTable.argument[cmdIndex].argCount], $2);
										cmdTable.argument[cmdIndex].argCount++;
										//argIndex++;
									};}
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
	//token = strtok(NULL, ":"); //this may need to be fixed depending on what they change the path to ".:"
	strcpy(pTable.paths[pathIndex], token);
	pathIndex++;
  		while (token != NULL)
  		{
		strcpy(pTable.paths[pathIndex], token);
		//printf("ptable: %s\n",pTable.paths[pathIndex]);
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
		// char* tkn = strtok(arg,"/");
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);
		char* token = &arg[1];
		printf("token: %s\n", token);
		if(strcmp(arg,"~") == 0){//bring home
			chdir(varTable.word[1]);
			strcpy(varTable.word[0], varTable.word[1]);
		}
		else if(strcmp(&arg[0],"~") == 0){
			printf("reached");
			char* temp;
			if (strcmp(token, "/") == 0){ //cd ~/testdir
				token = strtok("~", arg);
				printf("token: %s\n", token);
				strcpy(temp, strcat(varTable.word[1], arg));
				printf("token: %s\n", temp);
				if(!chdir(temp)){
					printf("Directory not found\n");
					return 1;
				}
				strcpy(varTable.word[0], temp);
			}
			else { //relative path
				token = strtok("~", arg);

				strcpy(temp, strcat(varTable.word[1], arg));

			}
		}
		else if(strcmp(arg,".") == 0){ 
			chdir(varTable.word[0]);
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			return 1;
		} 
		else if(strcmp(&arg[0],".") == 0){
			arg[0] = arg[0] + 1;
			chdir("HOME/..");
			if(chdir(arg[0]!=0)){
				arg[0]= getenv("HOME");
				chdir(varTable.word[1]);
				return 1;
			}
		}
		else if(strcmp(arg,"..") == 0){
			chdir("..");
			strcpy(varTable.word[0], getcwd(cwd, sizeof(cwd)));
			return 1;
		}
		else if(chdir(varTable.word[0]) == 0) {
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


int runSetAlias(char *name, char *word) {
	// alias a b
	// alias b c
	// alias c a
	for (int i = 0; i <= aliasIndex; i++) {
		if(strcmp(name, word) == 0){ 
			printf("Error1, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error2, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(!(strcmp(aliasTable.name[i], name) == 0) && !(strcmp(aliasTable.word[i], word) == 0)){ // a and b
			for (int j = 0; j < aliasIndex; j++){
				if((strcmp(aliasTable.name[j], word) == 0) && (strcmp(aliasTable.word[j], name) == 0)){
					printf("Error3, expansion of \"%s\" would create a loop.\n", name);
					return 1;
				}
			}
			//character array[][]
			//char* = passed in name to be checked against the others
			//continually check what the word of the previous name is equal to
		}
		// else if (!(strcmp(aliasTable.name[i], name) == 0) && !(strcmp(aliasTable.word[i], word) == 0)){
		// 	printf("here");
		// 	char* compn[100];
		// 	char* compw[100];
		// 	strcpy(compw, word);
		// 	int temp;

		// 	for (int j = 0; j < aliasIndex; j++){ //name
		// 	if (strcmp(compn, compw) == 0){
		// 		printf("Error4, expansion of \"%s\" would create a loop.\n", name);
		// 		return 1;
		// 	}
		// 	else if (strcmp(aliasTable.word[j], compn) == 0)){
		// 		temp = k;//we know that k at the name index is equal to the current 
		// 		compn = aliasTable.name[k];
		// 		j = 0;
		// 	}
		// 			for(int k = 0; j < aliasIndex; k++){ //word
		// 				if(strcmp(aliasTable.name[k], compw) == 0){
		// 					temp = k;//we know that k at the name index is equal to the current 
		// 					compn = aliasTable.name[k];
		// 					j = 0;
		// 					break; 
							
		// 				}
		// 		}
		// 	}
		// }
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


bool ifCmdPath(char** argPass, int currCommand){
	for (int i = 0; i < pathIndex; i++){ //get all paths
    char* path[2];
	char* temp[64];
	strcpy(temp, pTable.paths[i]);
	strcat(temp, "/");
	//printf("Temp path: %s\n", temp);
    path[0] = temp;
    path[1] = cmdTable.cmds[currCommand];
    char* npath = concatStr(path[0], path[1]);
	//printf("npath path: %s\n", npath);
    int fd = access(npath, F_OK);
    if(fd == -1 && i+1 == pathIndex){ //iterated through all, no directory exists
		printf("Error Number: %d\n", errno);
        perror("Error Description");
        return false;
	}
	else if(fd == -1){ //directory does not have command
		continue;
    }
    else { //command does exist
        //printf("%s\n", npath);
		//fpath = npath;
		argPass[0] = npath;
		for (int i = 1; i <= cmdTable.argument[currCommand].argCount; i++){
		argPass[i] = cmdTable.argument[currCommand].args[i-1];
		}
		argPass[cmdTable.argument[currCommand].argCount+1] = NULL;
		memset(temp, 0, sizeof(temp));
		//printf("true");
		return true;
    }	
}
}


int RunBinCommands(){
	int check;
	int count;
	char* argPass[cmdTable.argument[0].argCount+2]; //first command
	if (cmdIndex > 0) {
		//place pipes here
		RunPipes();
		return 1;
	}
	else {
		if (ifCmdPath(argPass, 0)){ //first command
			if (fork() == 0 ) {
				execve(argPass[0], argPass, NULL);
			}
			else{
				wait(&check);
				}
				cmdTable.argument[0].argCount = 0;
    			memset(cmdTable.argument[0].args, 0, sizeof(cmdTable.argument[0].args));
				return 1;
			}
	}
	cmdTable.argument[0].argCount = 0;
    memset(cmdTable.argument[0].args, 0, sizeof(cmdTable.argument[0].args));
	return 1; 
}
	// for (int i = 0; i < cmdTable.argument[0].argCount; i++){
	// 	printf("command[0] argument: %s\n", cmdTable.argument[0].args[i]);
	// }

void RunWildCardExpan(char* arg){
	//it will increase the command arg count for each command
	//it will change the given argument that is passed into it into more arguments 
	int count = 0;
	DIR *d;
  	struct dirent *dir;
  	d = opendir(".");
  	if (d) {
    	while ((dir = readdir(d)) != NULL) {
      		if(fnmatch(arg, dir->d_name, 0) == 0){
				//printf("%s\n", dir->d_name);
				strcpy(cmdTable.argument[cmdIndex].args[cmdTable.argument[cmdIndex].argCount], dir->d_name);
				//printf("args: %s\n", cmdTable.argument[cmdIndex].args[cmdTable.argument[cmdIndex].argCount]);
				cmdTable.argument[cmdIndex].argCount++;
				count++;
			  } 
    	}
    closedir(d);
  	}
	if(count == 0){
		printf("Error: %s does not exist in current directory.\n", arg);
		strcpy(cmdTable.cmds[cmdIndex], "");
	}
			  
//return;
}


void RunPipes(){
	int numPipes = cmdIndex; //0 is first, 1 is second
	pid_t pid;
	int fd[numPipes][2];

	for (int i = 0; i < numPipes; i++){ 
		pipe(fd[i]);
	}

	int ccmd = 0; //current command

	for(int i = 0; i <= numPipes; i++){
		char* argPass[cmdTable.argument[i].argCount+2];
		if (ifCmdPath(argPass, i)){
			//printf("argpass[0]: %s\n", argPass[0]);
			pid = fork();
			
			if(pid == 0){
				for (int j = 0; j < numPipes; j++){
					printf("j %i\n", j);
					if(j == i){ // open write side
						printf("argpass[0] write: %s\n", argPass[0]);
						dup2(fd[j][1], 1);
						close(fd[j][0]);
						close(fd[j][1]);
						perror("Error with write side of the pipe");
					}
					else if(j == i-1){ //open read side
						printf("argpass[0] read: %s\n", argPass[0]);
						close(fd[j][0]);
						dup2(fd[j][0], 0);
						close(fd[j][1]);
						perror("Error with read side of the pipe");
					} 
					else {
						close(fd[j][0]);
						close(fd[j][1]);
					}		
				}
					printf("argcount for %d: %d\n", i, cmdTable.argument[i].argCount);
					for (int i = 0; i < cmdTable.argument[i].argCount+2; i++){
						printf("command[0] argument: %s\n", argPass[i]);
					}
				execve(argPass[0], argPass, NULL);
				close(fd[i][0]);
				
				if(i > 0){
					close(fd[i-1][0]);
				}
				exit(0);
				
			} 
			else if(pid < 0){
				perror("fork failed");
				return;
			}
			waitpid(pid, 0, 0);		
		}	
		//mccmd++;
		memset(argPass, 0, sizeof(argPass));
	}
}
// 	Go through parent and child processes for however many pipes there are
// 	for(int i = 0; i <= numPipes; i++){
// 		char* argPass[argIndex+2];
// 		int currCommand = i;

// 		if (ifCmdPath(argPass, currCommand)){
// 		pid = fork();
// 		printf("int i: %d,", i);
// 		printf("pid = %ld\n", (long) pid);
		
// 		if(pid == 0){
// 			printf("enter 0");
// 			for (int j = 0; j < numPipes; j++){
// 				printf("enter 1");
// 				if(j == i){ // open write side
// 					printf("enter 2");
// 					dup2(fd[j][1], STDOUT_FILENO);
// 					close(fd[j][0]);
// 					printf("error");
// 				}
// 				else if(j == i -1){ //open read side
// 					dup2(fd[j][0], STDOUT_FILENO);
// 					close(fd[j][1]);
// 					printf("error");
// 				} 
// 				else {
// 					close(fd[j][0]);
// 					close(fd[j][1]);
// 				}
// 				execve(argPass[0], argPass, NULL);
// 				close(fd[i][0]);
// 				if(i > 0)
// 					close(fd[i-1][0]);
				
// 			}
// 		 	waitpid(pid, 0, 0);
// 		} else if(pid < 0){
// 			perror("fork failed");
// 			return;
// 		}
// 		else{
// 		cmdIndex = 0; 
// 		printf("big sad, pid is greater than 0 and idk why");
// 		} 
		
// 	}
// 	cmdIndex = 0;
// 		return;
// 	}
// 	cmdIndex = 0;
// 		return;
// }


// void RunPipes(){
// 	int numPipes = cmdIndex;
//     pid_t pid;
// 	int fd[2*numPipes];
// 	char* argPass[argIndex+2];
	
// 	/* parent creates all needed pipes at the start */
// 	for (int i = 0; i < numPipes; i++){ //number of pipes that we have
// 		if(pipe(fd + i*2) < 0){
// 			perror("did not create parent pipes");
// 			exit(EXIT_FAILURE);
// 			return;
// 		}
// 	}	
// 	int cmdc = 0; //command count

// 	while( cmdIndex !=0){ //while there are commands left
// 		pid = fork();
// 		if (pid == 0){ //there is a previous command
//  			printf("enter 2\n");
// 			dup2(fd[cmdIndex+1], STDOUT_FILENO);
//  			close(fd[cmdIndex]);
//  			printf("error");

// 			if(cmdIndex > 0){ // there is another command
// 				if(dup2(fd[(cmdc-1*2)], 0) < 0){
// 					perror("messed up");
// 					return;
// 				}
// 			}	
			
// 			if(cmdIndex != 0){ // ??
// 				if(dup2(fd[cmdc*2+1], 1) < 0){
// 					perror("messed up");
// 					return;
// 				}
// 			}
// 			for(int i  = 0; i < numPipes; i++){
// 				close(fd[(cmdc-1*2)]);
// 				close(fd[cmdc*2+1]);
// 			}
// 			execve(argPass[0], argPass, NULL); // took out arg pass should i add back in ??
// 			perror("did not execute correctly");
// 			exit(EXIT_FAILURE);
// 		}
// 		cmdIndex++; // increment command here *missing* ??
// 		cmdc++;
// 	}
// }






// }
// void RunPipes(){
// 	int numPipes = cmdIndex;
//     pid_t pid;
// 	int fd[numPipes][2];
	
// 	for (int i = 0; i < numPipes; i++){ //number of pipes that we have
// 		pipe(fd[i]);
// 	}
// 	// Go through parent and child processes for however many pipes there are
// 	for(int i = 0; i <= numPipes; i++){
// 		char* argPass[argIndex+2];
// 		int currCommand = i;

// 		if (ifCmdPath(argPass, currCommand)){
// 		pid = fork();
// 		printf("int i: %d,", i);
// 		printf("pid = %ld\n", (long) pid);
		
// 		if(pid == 0){
// 			printf("enter 0");
// 			for (int j = 0; j < numPipes; j++){
// 				printf("enter 1");
// 				if(j == i){ // open write side
// 					printf("enter 2");
// 					dup2(fd[j][1], STDOUT_FILENO);
// 					close(fd[j][0]);
// 					printf("error");
// 				}
// 				else if(j == i -1){ //open read side
// 					dup2(fd[j][0], STDOUT_FILENO);
// 					close(fd[j][1]);
// 					printf("error");
// 				} 
// 				else {
// 					close(fd[j][0]);
// 					close(fd[j][1]);
// 				}
// 				execve(argPass[0], argPass, NULL);
// 				close(fd[i][0]);
// 				if(i > 0)
// 					close(fd[i-1][0]);
				
// 			}
// 		 	waitpid(pid, 0, 0);
// 		} else if(pid < 0){
// 			perror("fork failed");
// 			return;
// 		}
// 		else{
// 		cmdIndex = 0; 
// 		printf("big sad, pid is greater than 0 and idk why");
// 		} 
		
// 	}
// 	cmdIndex = 0;
// 		return;
// 	}
// 	cmdIndex = 0;
// 		return;
// }