#include <stdio.h>

main()
{
	shell_init();
	While(1){
		printPrompt();
		Switch (CMD = getCommand()) {
		Case: BYE		exit();
		Case: ERRORS 	recover_from_errors();
		Case: OK 		processCommand();
		}
	}
}