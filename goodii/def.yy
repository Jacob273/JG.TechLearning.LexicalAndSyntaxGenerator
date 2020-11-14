%{
     #include <iostream>
     #include <stdbool.h>
     #include <stdio.h>
     #include <stdlib.h>
     #include <string>
     #include <vector>
     #include <stack>
     extern "C" int yylex();
     extern "C" int yyerror(const char *msg, ...);
	#define INFILE_ERROR 1
	#define OUTFILE_ERROR 2
     extern FILE *yyin;
     extern FILE *yyout;
%}

%{

class FileAppender{

     private:
          std::string _outputFileName;
     public:
          FileAppender(std::string outputFileName){
               _outputFileName = outputFileName;
          }

          bool tryClean()
          {
               return remove(_outputFileName.c_str()) == 0;
          }

          void append(std::string newText, bool includeSpace)
          {
               FILE *pFile;
               pFile = fopen(_outputFileName.c_str(), "a");
               std::string argumentTypeText = includeSpace == true ? " %s" : "%s";
               fprintf(pFile, argumentTypeText.c_str(), newText.c_str());  
               fclose(pFile);
          }
};

enum LexemType
{
    Txt,
    Integer,
    Double
};

class TextElement
{
	public:
		LexemType type; // lexem type 
		std::string _value; //could be integer: 1 or double 1.0 or literal?


     TextElement(LexemType type, std::string value)
     {
          _value = value;
     }
};

class GrammaBuilder 
{
     private:
     std::stack<TextElement*> *_stack;
     TextElement *_previousElement;
     std::vector<std::string>  *_assemblerOutputCode;
     
     public:

     GrammaBuilder(){
          _stack = new std::stack<TextElement*>();
          _assemblerOutputCode = new std::vector<std::string>();
     }

     void pushOnStack(TextElement *element)
     {
          if(_stack->size() > 0)
          {
               _previousElement = _stack->top();
          }
          _stack->push(element);
     }

     std::string buildCommentedTriple(std::string concatenator)
     {
          std::string commentedResult;
          if(_previousElement)
          {
               commentedResult = "#" + _previousElement->_value + concatenator + _stack->top()->_value;
          }
          else
          {
               commentedResult = "#" + concatenator + _stack->top()->_value;
          }
          _assemblerOutputCode->push_back(commentedResult);
          return commentedResult;
     }

};

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

FileAppender *fileAppender = new FileAppender("output_goodii.txt");
GrammaBuilder *builder = new GrammaBuilder();

int main (int argc, char *argv[]) 
{
     fileAppender->tryClean();
     fileAppender->append("HEADER FILE", false);

     //Test code

     builder->pushOnStack(new TextElement(LexemType::Integer, "1"));
     builder->pushOnStack(new TextElement(LexemType::Integer, "2"));
     std::string commentedTriple1 = builder->buildCommentedTriple("+");
     
     builder->pushOnStack(new TextElement(LexemType::Integer, "5"));
     std::string commentedTriple2 = builder->buildCommentedTriple("*");

     fileAppender->append(commentedTriple1, true);
     fileAppender->append(commentedTriple2, true);

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


     //Zadanie: zrzucic stack do trojki
     // 1 + 2 * 5                       wyrazenie wejsciowe
     
     // rpn.txt 1 2 5 * +               zapis wyrazenia wejsciowego w odwrotnej notacji polskiej
     
     // threes.txt tmp 1 2 +            plik trójkowy
     // tmp1 = 2 * 5
     // tmp2 = 1 tmp1 
     
     // **kod wyjsciowy**
     // li $t0, 1
     // li $t1, 2
     // add $t0, $t0, $t1
     // sw $t1, tmp

**/
