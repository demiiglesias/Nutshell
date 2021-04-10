#include <unistd.h>
#include <stdio.h>
#include <errno.h>
int main(){
    char* argv[2];
    argv[0] = "/bin/pwd";
    argv[1] = NULL;
    int fd = access(argv[0], F_OK);
    if(fd == -1){
        printf("Error Number : %d\n", errno);
        perror("Error Description:");
    }
        else
        printf("No error\n");

    execve(argv[0], argv, NULL);
    return 0;

}