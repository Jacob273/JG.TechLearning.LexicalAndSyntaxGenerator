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

%start lines;
%right '='
%left '+' '-'
%left '*'

/** Tokens **/
%token<integerValue> NUMBER;
%token<textValue> TEXT;
%token INT DOUBLE STRINGI BOOLEAN;
%token IF ELSE WHILE RETURN;
%token READ PRINT;
%token TRUE FALSE COMMENT;
%token EQ NEQ GEQ LEQ;

%token VALUE_INTEGER;
%token VALUE_DECIMAL;

/** Syntax rules definition **/
%%


lines:
       line
     | lines line   { printf("Syntax-Recognized: wiele linii\n"); }
     ;

line:
       declaration  { printf("Syntax-Recognized: linia deklaracji\n");}
     | assignment  { printf("Syntax-Recognized: linia przypisania\n");}
     ;
     
assignment:
	      typeName elementCmp '=' elementCmp ';' { printf("Syntax-Recognized: przypisanie proste.\n");  }
      | 	 typeName elementCmp '=' expression ';' { printf("Syntax-Recognized: przypisanie zlozone.\n");  }
	;

declaration:
     typeName elementCmp ';' { printf("Syntax-Recognized: deklaracja\n"); }
     ;

typeName:
       INT    {  printf("Syntax-Recognized: typ int\n"); }
     | DOUBLE {  printf("Syntax-Recognized: typ double\n"); }
     | STRINGI {  printf("Syntax-Recognized: typ string\n"); }
     | BOOLEAN {  printf("Syntax-Recognized: typ bool\n"); }
      ;

expression:
       components '+' expression {  printf("Syntax-Recognized: dodawanie\n"); }
	| components '-' expression {  printf("Syntax-Recognized: odejmowanie\n"); }
	| components
	;

components:
	  components '*' elementCmp {  printf("Syntax-Recognized: mnozenie\n"); }
	| components '/' elementCmp {  printf("Syntax-Recognized: dzielenie\n"); }
	| elementCmp                 {  printf("(konkretnaWartosc)\n"); }
	;

elementCmp:
	  VALUE_INTEGER			{  printf("Syntax-Recognized: wartosc calkowita\n"); }
	| VALUE_DECIMAL			{  printf("Syntax-Recognized: wartosc zmiennoprzecinkowa\n");  }
     | TEXT                        { printf("Syntax-Recognized: text-zmn\n"); }
	;

%%

bool firstTimeExecution = true;
std::string outputFileName = "output_goodii.txt";
std::vector<std::string> goodiiCode;

int main (int argc, char *argv[]) 
{
     /** glowna petla odpytujaca analizator leksykalny yyparse()**/
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
