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

shell_init()
{
	// init all variables. 
	// define (allocate storage) for some var/tables
	// init all tables (e.g., alias table, command table)
	// get PATH environment variable (use getenv())
	// get HOME env variable (also use getenv())
	// disable anything that can kill your shell. 
	// (the shell should never die; only can be exit)
	// do anything you feel should be done as init
}

getCommand()
{
	init_scanner-and_parser(); 
	if (yyparse()) 
		understand_errors();
	else
		Return (OK);
}

recover_from_errors()
{
	// Find out if error occurred in middle of command,
	// that is, the command still has a “tail”
	// In this case you have to recover by “eating”
	// the rest of the command.
	// To do this: you may want to use yylex() directly, or 
	// handle clear things up in any other way. 
}

processCommand()
{
	if (builtin) 
		do_it();		// run built-in commands – no fork
				// no exec; only your code + Unix
				//system calls. 
	else 
		execute_it();	// execute general commands
				//using fork and exec
}

do_it()
{
	switch (builtin) {
	  case ALIAS		// e.g., alias(); alias(name, word);
	  case CDHome  	// e.g., gohome();
	  case CDPath   	// e.g., chdir(path);	
	  case UNALIAS 
	  case SETENV
	  case PRINTENV 
	}
}

execute_it()
{
	// Handle  command execution, pipelining, i/o redirection, 
	// and background processing. 
	// Utilize a command table whose components are 
	// plugged in during parsing by yacc. 

/*  Check Command Accessibility and Executability */
	if( ! Executable() ) {  
		//use access() system call.
		nuterr("Command not Found");
		return;
	}
	/* Check io file existence in case of io-redirection.	*/
	
    if( check_in_file()==SYSERR ) {
		nuterr("Cann't read from : %s",srcf);
		return;
	}
	if( check_out_file()==SYSERR ) {
		nuterr("Cann't write to : %s",distf);
		return;
	}
	//Build up the pipeline (create and set up pipe 
	// end points (using pipe, dup) 
	//Process background
}

processAlias ()
{	
	while (1) {
		if (alias_input(cmd))	
			// if command has alias, check alias table 					// and expand it
		else
			break;
	}
}