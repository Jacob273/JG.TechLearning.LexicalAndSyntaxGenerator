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
void appendToOutputFile(char* newText);
bool removeFile(char* path);
%}

%union 
{
	char *textValue;
	int	integerValue;
};


/** Tokens **/
%nterm <textValue> item;
%token<textValue> TEXT;
%token<integerValue> NUMBER;
%start program
%right '='
%left '+' '-'
%left '*'
%token<textValue> INT

/* Rules Definition */
%%

program:
     item item { appendToOutputFile($1); appendToOutputFile($2);}
     ;

item:
       TEXT    { $$ = $1; }
     | NUMBER  { 
                 char bufferForString[100];
                 sprintf(bufferForString, "%d", $1);
                 $$ = bufferForString; 
               }
     | INT     { $$ = $1; }
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

bool wasFileDeleted = false;
char* outputFileName = "output_goodii.txt";

void appendToOutputFile(char* newText){

     if(!wasFileDeleted)
     {
          if(removeFile(outputFileName))
          {
               printf("Deleted output file...");
               wasFileDeleted = true;
          }
     }

     printf("Appending text to output....: \n%s\n", newText);
     FILE *pFile;
     pFile = fopen(outputFileName,"a");
     fprintf(pFile, " %s", newText);
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
**/
