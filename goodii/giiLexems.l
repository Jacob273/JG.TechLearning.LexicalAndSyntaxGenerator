%{
#include <stdlib.h>
#include <string.h>
#include "def.tab.hh"
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
stringii				{ 
							yylval.textValue = strdup("string");
							return STRINGI;
						}
boolii					{ 
							yylval.textValue = strdup("bool");
							return BOOLEAN;
						}
\+						{ 
							yylval.textValue = strdup("+");
							return ADD_OPERATOR; 
						}
\=						{ 
							yylval.textValue = strdup("=");
							return ASSIGNMENT_OPERATOR; 
						}
[A-Za-z_][A-Za-z0-9_]*	{ 
							yylval.textValue = strdup(yytext);
							return TEXT;
						}
[1-9][0-9]*|0			{
							yylval.integerValue = atoi(yytext);
							return VALUE_INTEGER;
						}
([1-9][0-9]*|0)\.[0-9]+ {
							yylval.decimalValue = atof(yytext);
							return VALUE_DECIMAL;
						}		
[ \t]					{;}
;						{
							yylval.textValue = strdup(";");
							return SEMICOLON;
						}
[\n]					{  yylineno++; }
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
