%{
#include <stdlib.h>
#include <string.h>
#include "def.tab.h"
#define INFILE_ERROR 1
#define OUTFILE_ERROR 2
extern int yylineno;
int yyerror(char *,...);
void sendToOutputStream(char *);
%}

%%
intii					{ 
							yylval.textValue = strdup("int");
							return INT;
						} 
dublii					{ 
							yylval.textValue = strdup("double");
							return DOUBLE;
						} 		
\+						{ sendToOutputStream("LEX::+"); } 
\*						{ sendToOutputStream("LEX::*"); }
\(						{ sendToOutputStream("LEX::("); }
\)						{ sendToOutputStream("LEX::)"); }
\/						{ sendToOutputStream("LEX::/"); }
\-						{ sendToOutputStream("LEX::-"); }
\^						{ sendToOutputStream("LEX::^"); }
\=						{ sendToOutputStream("LEX::="); }
[1-9][0-9]*				{ sendToOutputStream(yytext); }	
[A-Za-z_][A-Za-z0-9_]*	{ 
							yylval.textValue = strdup(yytext);
							return TEXT;
						}
[1-9]+[.]{2}			{ sendToOutputStream("LEX::DECIMAL");}
\ |\t					{;}
;						{
							yylval.textValue = strdup(";");
							return SEMICOLON;
						}
\n						{  yylineno++; 
							yylval.textValue = strdup("\n");
							return NEWLINE;
						}
.						{ yyerror("LEX::Lexical error....\n");}
%%

void sendToOutputStream(char *value)
{
	fprintf(yyout, "%s\n", value);
}

int yyerror(char *msg,...)
{
	printf("%d: %s", yylineno, msg);
	exit(1);
}
