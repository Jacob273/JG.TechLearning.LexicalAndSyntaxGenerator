%{
int yylex();
void yyerror(const char *s);
void appendToOutput(char* newText);
%}

%{
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>
	#define INFILE_ERROR 1
	#define OUTFILE_ERROR 2
     extern FILE *yyin;
     extern FILE *yyout;
%}

%union 
{
	char *textValue;
	int	integerValue;
};

%nterm <textValue> item;
%token<textValue> TEXT;
%token<integerValue> NUMBER;
%start program
/* Rules Definition */
%%

program:
     item { appendToOutput($1); }
     ;

item:
       TEXT { $$ = $1; }
     ;
%%

/**

| NUMBER  { printf("BIS::NUMBER\n"); $$ = $1; }
The Bison parser detects a syntax error (or parse error)
 whenever it reads a token which cannot satisfy any syntax rule.
**/

/**
yyparse() reads a stream 
of token/value pairs from yylex(), which needs to be supplied. Y
**/

int main (int argc, char *argv[]) 
{
     // FILE *pt = fopen("output.txt", "w" );
     // if(!pt)
     // {
     //      fputs("Bad Input! File does not exist.", stdout);
     //      return -1;
     // }
     //      if(yyparse() == 0)
     //      {
     //           fputs ("Succesfull parsing", stdout);
     //      }
     //      else
     //      {
     //            fputs("Error occured while parsing.", stdout);
     //      }


     
     return yyparse();
     // fclose(pt);
}

void appendToOutput(char* newText){
     printf("appending to output %s", newText);
     FILE *pFile;
     pFile = fopen("output.txt","w");
     fprintf(pFile, "%s", newText);
     fclose(pFile);
}
