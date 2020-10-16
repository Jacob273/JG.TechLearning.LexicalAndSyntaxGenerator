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
};

/** Tokens **/
%nterm<textValue> typeName var semiColon;
%start program;

%right '='
%left '+' '-'
%left '*'

%token<integerValue> NUMBER;
%token<textValue> TEXT;
%token<textValue> INT;
%token<textValue> DOUBLE;
%token<textValue> STRINGI;
%token<textValue> SEMICOLON;
%token<textValue> VAR;
%token<textValue> BOOLEAN;

/** Rules Definition **/
%%

program:
     expression 
     | expression program
     ;

expression:
     typeName var semiColon
                          { 
                              appendToOutputFile(std::string($1), false); 
                              appendToOutputFile(std::string($2), true); 
                              appendToOutputFile(std::string($3), false);
                           }
     ;


semiColon:
     SEMICOLON
     ;

var:
     TEXT 
     ;


typeName:
       INT
     | DOUBLE
     | STRINGI
     | BOOLEAN
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
     goodiiCode.push_back(newText);
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

     | NUMBER  { 
                 char bufferForString[100];
                 sprintf(bufferForString, "%d", $1);
                 $$ = bufferForString; 
               }

**/
