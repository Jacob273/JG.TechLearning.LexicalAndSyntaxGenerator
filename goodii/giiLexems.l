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
intii					{ return INT; } 
dublii					{ return DOUBLE; }
stringii				{ return STRINGI; }
boolii					{ return BOOLEAN; }
\+						{ return '+'; }
\-						{ return '-'; }
\=						{ return '='; }
\/						{ return '/'; }
\*						{ return '*'; }
;						{ return ';'; }
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
