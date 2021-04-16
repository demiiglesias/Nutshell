#include <stdio.h>
#include <fnmatch.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#define WRITE_END 1
#define READ_END 0

int main(){
    pid_t pid;
    int fd[2][2];
    char* lsargs[2];
    lsargs[0] = "/bin/ls";
    lsargs[1] = NULL;

    char* wcargs[2];
    wcargs[0] = "/bin/wc";
    wcargs[1] = NULL;

    char* wclargs[2];
    wclargs[0] = "/bin/wc";
    wclargs[1] = "-l";
    wclargs[2] = NULL;

    char** args;
    for (int i = 0; i < 2; i++){ 
        pipe(fd[i]);
    }

    for (int i = 0; i <= 2; i++){
        pid = fork();
        if(pid==0){
            for (int j = 0; j < 2; j++){
                if (j == i){
                    dup2(fd[j][WRITE_END], STDOUT_FILENO);
                    close(fd[j][READ_END]);
                    perror("Error with write side of the pipe");
                }
                else if(j == i-1){ //open read side
                    //printf("argpass[0] read: %s\n", argPass[0]);
                    dup2(fd[j][READ_END], STDIN_FILENO);
                    close(fd[j][WRITE_END]);
                    perror("Error with read side of the pipe");
                }
                else{
                    close(fd[j][READ_END]);
                    close(fd[j][WRITE_END]);
                }   
            }
            if(i == 0){
                args = lsargs;
            }
            else if(i == 1){
                args = wcargs;
            }
            else if(i == 2){
                args = wclargs;
            }

            execv(args[0], args);
            fprintf(stderr, "Failed to execute '%s'\n", args[0]);

            close(fd[i][WRITE_END]);
            close(fd[i][READ_END]);
            exit(0);
        }   
    }
    //printf("finished forking\n");
    for(int i = 0; i < 2; i++){
        close(fd[i][READ_END]);
        close(fd[i][WRITE_END]);
    }
    int status;
    waitpid(pid, &status, 0);
    return 1;
}



//int numPipes = cmdIndex; //0 is first, 1 is second
	// pid_t pid;
	// int fd[numPipes][2];

	// for (int i = 0; i < numPipes; i++){ 
	// 	pipe(fd[i]);
	// }

	// int ccmd = 0; //current command

	// for(int i = 0; i <= numPipes; i++){
	// 	char* argPass[cmdTable.argument[i].argCount+2];
	// 	if (ifCmdPath(argPass, i)){
	// 		//printf("argpass[0]: %s\n", argPass[0]);
	// 		pid = fork();
			
	// 		if(pid == 0){
	// 			for (int j = 0; j < numPipes; j++){
	// 				printf("j %i\n", j);
	// 				if(j == i){ // open write side
	// 					printf("argpass[0] write: %s\n", argPass[0]);
	// 					dup2(fd[j][1], 1);
	// 					close(fd[j][0]);
	// 					close(fd[j][1]);
	// 					perror("Error with write side of the pipe");
	// 				}
	// 				else if(j == i-1){ //open read side
	// 					printf("argpass[0] read: %s\n", argPass[0]);
	// 					close(fd[j][0]);
	// 					dup2(fd[j][0], 0);
	// 					close(fd[j][1]);
	// 					perror("Error with read side of the pipe");
	// 				} 
	// 				else {
	// 					close(fd[j][0]);
	// 					close(fd[j][1]);
	// 				}		
	// 			}
	// 				printf("argcount for %d: %d\n", i, cmdTable.argument[i].argCount);
	// 				for (int i = 0; i < cmdTable.argument[i].argCount+2; i++){
	// 					printf("command[0] argument: %s\n", argPass[i]);
	// 				}
	// 			execve(argPass[0], argPass, NULL);
	// 			close(fd[i][0]);
				
	// 			if(i > 0){
	// 				close(fd[i-1][0]);
	// 			}
	// 			exit(0);
				
	// 		} 
	// 		else if(pid < 0){
	// 			perror("fork failed");
	// 			return;
	// 		}
	// 		waitpid(pid, 0, 0);		
	// 	}	
	// 	//mccmd++;
	// 	memset(argPass, 0, sizeof(argPass));
	// }
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