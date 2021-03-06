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
\;						{ return ';'; }
"ifi"					{ return IF;      } 
"elsi"					{ return ELSE;    }
"whili"					{ return WHILE;   }  
"printi"				{ return PRINT;   }
"ridi"					{ return READ;    }  
"returni"				{ return RETURN;  }  
"goodii"				{ return TRUE;    } 
"badii"					{ return FALSE;   }  
\/\/					{ return COMMENT; }
\(						{ return '(';     }
\)						{ return ')';     }
\[						{ return '[';     }
\{						{ return '{';     }
\}						{ return '}';     }
\"						{ return '"';     }
\]						{ return ']';     }

\/\/					{ return COMMENT;}

\=\=					{ return EQ;}
\>\=					{ return GEQ;}
\<\=					{ return LEQ;}
\!\=					{ return NEQ;}

\>						{return LARGER;}
\<						{return SMALLER;}

[A-Za-z_][A-Za-z0-9_]*	{ 
							yylval.textIdentifier = strdup(yytext);
							return TEXT_IDENTIFIER;
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
[\r][\n]					{  yylineno++; }
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