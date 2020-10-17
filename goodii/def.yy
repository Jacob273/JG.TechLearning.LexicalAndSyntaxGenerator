%{
     #include <iostream>
     #include <stdbool.h>
     #include <stdio.h>
     #include <stdlib.h>
     #include <string>
     #include <vector>
     extern "C" int yylex();
     extern "C" int yyerror(const char *msg, ...);
	#define INFILE_ERROR 1
	#define OUTFILE_ERROR 2
     extern FILE *yyin;
     extern FILE *yyout;
%}

%{
void appendToOutputFile(std::string newText, bool addSpace);
bool removeFile(std::string path);
void printInfo(std::string newText);
%}

%union 
{
	char *textValue;
	int	integerValue;
     double decimalValue;
};

/** Tokens **/

%start program;

%right '='
%left '+' '-'
%left '*'

%token<integerValue> NUMBER;
%token<textValue> TEXT;
%token INT;
%token DOUBLE;
%token STRINGI;
%token SEMICOLON;
%token VAR;
%token BOOLEAN;
%token VALUE_INTEGER;
%token VALUE_DECIMAL;
%token MEQ;
%token LEQ;
%token NEQ;
%token EQ;
%token EXPRESSION;
%token COMPONENTS;
%token ELEMENT;
%token ASSIGNMENT_OPERATOR;
%token ADD_OPERATOR;

/** Rules Definition **/
%%

program:
       line         { printf("linia\n");}
     | program line { printf("linia z programu\n"); }
     ;

line:
       declaration
     | declaration line 
     | assignment
     | assignment line
     ;
     
assignment:
	      typeName var '=' elementCmp { printf("Rozpoznano przypisanie.\n");  }
      | 	 typeName var '=' expression { printf("Rozpoznano przypisanie.\n");  }
	;

declaration:
     typeName var ';' { printf("Rozpoznano deklaracje.\n"); }
     ;


var:
     TEXT { printf("Rozpoznano text\n"); }
     ;


typeName:
       INT {  printf("Rozpoznano typ int\n"); }
     | DOUBLE {  printf("Rozpoznano typ double\n"); }
     | STRINGI {  printf("Rozpoznano typ string\n"); }
     | BOOLEAN {  printf("Rozpoznano typ bool\n"); }
      ;

expression:
       components '+' expression {  printf("Rozpoznano dodawanie\n"); }
	| components '-' expression {  printf("Rozpoznano odejmowanie\n"); }
	| components
	;

components:
	  components '*' elementCmp {  printf("Rozpoznano mnozenie\n"); }
	| components '/' elementCmp {  printf("Rozpoznano dzielenie\n"); }
	| elementCmp                 {  printf("(konkretnaWartosc)\n"); }
	;

elementCmp:
	  VALUE_INTEGER			{  printf("Rozpoznano wartosc calkowita\n"); }
	| VALUE_DECIMAL			{  printf("Rozpoznano wartosc zmiennoprzecinkowa\n");  }
	;

%%

bool firstTimeExecution = true;
std::string outputFileName = "output_goodii.txt";
std::vector<std::string> goodiiCode;

int main (int argc, char *argv[]) 
{
     int parsingResult = yyparse();
     if(parsingResult == 0)
     {
          fputs("Succesfull parsing", stdout);
     }
     else
     {
          fputs("Error occured while parsing.", stdout);
     }

     return parsingResult;
}


void appendToOutputFile(std::string newText, bool includeSpace){
     if(firstTimeExecution)
     {
          if(removeFile(outputFileName.c_str()))
          {
               printf("Deleted output file...\n");
               firstTimeExecution = false;
          }
     }
     printInfo(newText); 
     FILE *pFile;
     pFile = fopen(outputFileName.c_str(), "a");
     std::string argumentTypeText = includeSpace == true ? " %s" : "%s";
     fprintf(pFile, argumentTypeText.c_str(), newText.c_str());  
     fclose(pFile);
}

bool removeFile(std::string path){
     return remove(path.c_str()) == 0;
}

void printInfo(std::string newText){
     if(newText == "\n")
     {
          newText = "NEWLINE";
     }
     std::cout << "Appending text to a file:<" << newText <<">" << "\n";
}

/** Documentation
==================================================================================================
'Bison'
     The Bison parser detects a syntax error (or parse error)
     whenever it reads a token which cannot satisfy any syntax rule.
=================================================
'yyparse()'
     reads a stream of token/value pairs from yylex(), 
     which needs to be supplied. Y
==================================================================================================
'%left %right'
     The associativity of an operator op determines how repeated uses of 
     the operator nest: whether ‘x op y op z’ is parsed by grouping 
     x with y first or by grouping y with z first.
==================================================================================================


**/
