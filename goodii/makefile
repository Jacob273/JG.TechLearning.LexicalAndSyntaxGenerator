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

runTests: runTest1 runTest2 runTest3 runTest4 runTest5 runTest6 runTest7

runTest1:
	./giiCompiler < test1_deklaracje.txt

runTest2:
	./giiCompiler < test2_deklaracjeRozne.txt

runTest3:
	./giiCompiler < test3_przypisywanie.txt

runTest4:
	./giiCompiler < test4_dodawanie.txt

runTest5:
	./giiCompiler < test4_odejmowanie.txt

runTest6:
	./giiCompiler < test5_operacjeArytmetyczneDouble.txt

runTest7:
	./giiCompiler < test5_operacjeArytmetyczneInt.txt


clean:
	rm *.o giiCompiler def.tab.cc lex.yy.c
