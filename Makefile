CC=/usr/bin/cc

all:  bison-config flex-config nutshell

bison-config:
	bison -d -t nutshparser.y

flex-config:
	flex -d nutshscanner.l

nutshell: nutshell.c nutshparser.tab.c lex.yy.c
	$(CC) nutshell.c nutshparser.tab.c lex.yy.c -o nutshell

clean:
	rm nutshparser.tab.c nutshparser.tab.h lex.yy.c nutshell