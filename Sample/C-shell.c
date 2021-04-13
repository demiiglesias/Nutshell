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
int main(int argc, char *argv[])
{
    glob_t  paths;
    int     csource;
    char    **p;
     
    printf("argv[0] = %s\n", argv[0]);
    printf("argv[1] = %s\n", argv[1]);  /* Argument I want to use as pathname */
     
    /* Find all ".c" files in given directory*/
    csource = glob("*.c", 0, NULL, &paths);
     
    if (csource == 0)
    {
        for (p=paths.gl_pathv; *p != NULL; ++p)
            puts(*p);
        globfree(&paths);
    }