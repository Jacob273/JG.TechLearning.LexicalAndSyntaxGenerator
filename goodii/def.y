%{
     #include <stdbool.h>
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>
	#define INFILE_ERROR 1
	#define OUTFILE_ERROR 2
     extern FILE *yyin;
     extern FILE *yyout;
%}

%{
int yylex();
void yyerror(const char *s);
void appendToOutputFile(char* newText, bool addSpace);
bool removeFile(char* path);
%}

%union 
{
	char *textValue;
	int	integerValue;
};


/** Tokens **/
%nterm<textValue> typeName var semiColon newLine;
%start program;

%right '='
%left '+' '-'
%left '*'

%token<textValue> TEXT;
%token<integerValue> NUMBER;
%token<textValue> INT;
%token<textValue> DOUBLE;
%token<textValue> SEMICOLON;
%token<textValue> VAR;
%token<textValue> NEWLINE;

/* Rules Definition */
%%

program:
     expression newLine expression 
     ;

expression:
     typeName var semiColon
                          { 
                              appendToOutputFile($1, false); 
                              appendToOutputFile($2, true); 
                              appendToOutputFile($3, false);
                           }
     ;

newLine:
     NEWLINE {  appendToOutputFile($1, false); }

semiColon:
     SEMICOLON
     ;

var:
     TEXT 
     ;


typeName:
       INT
     | DOUBLE
      ;



%%

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

bool firstTimeExecution = true;
char* outputFileName = "output_goodii.txt";

void appendToOutputFile(char* newText, bool includeSpace){


     if(firstTimeExecution)
     {
          if(removeFile(outputFileName))
          {
               printf("Deleted output file...\n");
               firstTimeExecution = false;
          }
     }

     printf("Appending text to output....: \n%s\n", newText);
     FILE *pFile;
     pFile = fopen(outputFileName, "a");
     char* argumentTypeText = includeSpace == true ? " %s" : "%s";
     fprintf(pFile, argumentTypeText, newText);  
     fclose(pFile);
}

bool removeFile(char* path){
     return remove(path) == 0;
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
