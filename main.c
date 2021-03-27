#include <stdio.h>

main()
{
	shell_init();

		printPrompt();
	    Switch (CMD = getCommand()) {
		Case: BYE		exit();
		Case: ERRORS 	recover_from_errors();
		Case: OK 		processCommand();
		
	}
}