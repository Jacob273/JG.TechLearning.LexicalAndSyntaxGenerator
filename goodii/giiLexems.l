%{
#include <stdlib.h>
#include <string.h>
#include "def.tab.h"
#define INFILE_ERROR 1
#define OUTFILE_ERROR 2
extern int yylineno;
int yyerror(char *,...);
void printLexValue(char *);
%}

%%
intii					{ printLexValue("LEX::int");} 
\+						{ printLexValue("LEX::+"); } 
\*						{ printLexValue("LEX::*"); }
\(						{ printLexValue("LEX::("); }
\)						{ printLexValue("LEX::)"); }
\/						{ printLexValue("LEX::/"); }
\-						{ printLexValue("LEX::-"); }
\^						{ printLexValue("LEX::^"); }
\=						{ printLexValue("LEX::="); }
[1-9][0-9]*				{ printLexValue("LEX::NUM"); }	
[A-Za-z_][A-Za-z0-9_]*	{ 
							printLexValue("LEX::text");
							yylval.textValue = strdup(yytext);
							return TEXT;
						}
[1-9]+[.]{2}			{ printLexValue("LEX::DECIMAL");}
\ |\t					{;}
;						{;}
\n						{ yylineno++;}
.						{ yyerror("LEX::Lexical error....\n");}
%%

void printLexValue(char *value)
{
	fprintf(yyout, "%d::%s\n", yylineno, value);
}

int yyerror(char *msg,...)
{
	printf("%d: %s", yylineno, msg);
	exit(1);
}
