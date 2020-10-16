CC=gcc
LEX=flex
YACC=bison
LD=gcc
CPP=g++
LD=g++

all:	giiCompiler

giiCompiler:	def.tab.o lex.yy.o
	$(CPP) -std=c++11 lex.yy.o def.tab.o -o giiCompiler -ll

lex.yy.o:	lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: giiLexems.l
	$(LEX) giiLexems.l

def.tab.o:	def.tab.cc
	$(CPP)  -std=c++11 -c def.tab.cc

def.tab.cc:	def.yy
	$(YACC) -d def.yy

clean:
	rm *.o giiCompiler def.tab.cc lex.yy.c
