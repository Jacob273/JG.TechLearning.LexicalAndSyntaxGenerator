CC=gcc
LEX=flex
YACC=bison
LD=gcc

all:	giiCompiler

giiCompiler:	def.tab.o lex.yy.o
	$(CC) lex.yy.o def.tab.o -o giiCompiler -ll

lex.yy.o:	lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: giiLexems.l
	$(LEX) giiLexems.l

def.tab.o:	def.tab.c
	$(CC) -c def.tab.c

def.tab.c:	def.y
	$(YACC) -d def.y

clean:
	rm *.o giiCompiler def.tab.c lex.yy.c
