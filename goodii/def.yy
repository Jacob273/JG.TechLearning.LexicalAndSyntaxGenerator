%{
     #include <iostream>
     #include <stdbool.h>
     #include <stdio.h>
     #include <stdlib.h>
     #include <string>
     #include <vector>
     #include <stack>
     #include <map>

     extern "C" int yylex();
     extern "C" int yyerror(const char *msg, ...);
	#define INFILE_ERROR 1
	#define OUTFILE_ERROR 2
     extern FILE *yyin;
     extern FILE *yyout;
%}

%{

namespace Constants
{
     std::string Subtraction = "-";
     std::string Addition = "+";
     std::string Multiplication = "*";
     std::string Division = "/";
     std::string Result = "result";
     std::string IntegerTypeDefaultValue = "0";
}

class UniqueIdGenerator
{

     static int resultCounter;
     static int triplesInvocationCounter;

     public:

     static int GetNextUniqueResult()
     {
          return ++resultCounter;
     }

     static int GetNextUniqueInvocationCounter()
     {
          return ++triplesInvocationCounter;
     }
};

int UniqueIdGenerator::resultCounter = 0;
int UniqueIdGenerator::triplesInvocationCounter = 0;

class FileAppender
{

     private:
          std::string _outputFileName;
     public:
          FileAppender(std::string outputFileName)
          {
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
    Unknown = 0,
    Txt = 1,
    Integer = 2,
    Double = 3
};

/**
Klasa służąca do przechowywania:
-Zmiennych(Txt)-
-Wartości całkowitych(Integer)
-Wartości zmiennoprzecinkowych(Double)

np. 
     'a = 5;'
to 
     TextElement.type = Integer;
     TextElement.value = 5;
lub
     'int a;'
to 
     TextElement.Txt 
     TextElement.value = a;
**/
class TextElement
{
	public:
		LexemType _type; // lexem type 
		std::string _value; //could be integer: 1 or double 1.0 or literal


     TextElement(LexemType type, std::string value)
     {
          _value = value;
          _type = type;
     }

     std::string GetValueAndTypeAsMessage()
     {
          return "<Value:<" + _value + ">" + ",Type:<" + std::to_string(_type) + ">>";
     }
};

/**
 Klasa służąca do:
 a) Zapisywania elementów tekstowych (TextElement) kodu goodii tworzących później gramatykę
 b) Tworzenia kodu wynikowego assemblera zbudowanego wg. określonych reguł gramatyki
 c) Tworzenia tablicy symboli
**/
class GrammaBuilder 
{
     private:

     //Przechowuje TextElement'y języka goodii. 
     //TextElementy mogą być zorganizowane w odpowiedniej kolejności, gdy dochodzi do wykrycia operacji arytmetycznych (triples).
     std::stack<TextElement*> *_allTextElementsStack;

     TextElement *_beforeTopElement;
     std::vector<std::string>  *_assemblerOutputCode;
     std::map<std::string, TextElement*> *_symbols;
     std::string _currResult;
     std::string _langVersion = "v. 1.0";

     FileAppender *_triplesOutputFileAppender;
     FileAppender *_assemblerOutputFileAppender;

     TextElement* GetAndRemove()
     {
         if (_allTextElementsStack->size() > 0)
         {
             TextElement* tmp = _allTextElementsStack->top();
             _allTextElementsStack->pop();
             return tmp;
         }
         return nullptr;
     }

     std::string GenerateTripleResultString(std::string arithmeticOperator, TextElement* first, TextElement* second)
     {
          return first->_value + arithmeticOperator + second->_value;
     }

     std::string GetResultStringWithId()
     {
          int nextId = UniqueIdGenerator::GetNextUniqueResult();
          return Constants::Result + "_" + std::to_string(nextId);
     }

     bool CheckTypeConsistency(LexemType firstType, LexemType secondType)
     {
          //std::cout << "GrammarBuilder:Comparing<" << std::to_string(firstType) << ">vs<" << std::to_string(secondType) << ">" << std::endl;

          return (firstType == LexemType::Double && secondType == LexemType::Double) 
                 || (firstType == LexemType::Integer && secondType == LexemType::Integer);
     }

     bool CanGenerateArithmeticForInts(LexemType type1, LexemType type2)
     {
          return type1 == LexemType::Integer || type2 == LexemType::Integer;
     }

          bool CanGenerateArithmeticForDoubles(LexemType type1, LexemType type2)
     {
          return type1 == LexemType::Double || type2 == LexemType::Double;
     }

     void ExecuteTypeValidation(TextElement* first, TextElement* second, LexemType typeFromSymbol1, LexemType typeFromSymbol2, std::string arithmeticOperator)
     {
          // (symbol vs symbol)
          if((typeFromSymbol1 != LexemType::Unknown && typeFromSymbol2 != LexemType::Unknown) && (!CheckTypeConsistency(typeFromSymbol1, typeFromSymbol2)))
          {
               std::string debugMessage = "First:" + std::to_string(typeFromSymbol1) + "| Second:" + std::to_string(typeFromSymbol2);
               std::string errorMessage = "Goodii language <" + _langVersion + "> does not support expression which as has both double and int. Operation: '" + arithmeticOperator + "' \n" + debugMessage;
               yyerror(errorMessage.c_str());
               return;
          }   
          // (value vs value)
          else if((typeFromSymbol1 == LexemType::Unknown && typeFromSymbol2 == LexemType::Unknown) && (!CheckTypeConsistency(first->_type, second->_type)))
          {
               std::string debugMessage = "First:" + first->GetValueAndTypeAsMessage() + "| Second:" + second->GetValueAndTypeAsMessage();
               std::string errorMessage = "Goodii language <" + _langVersion + "> does not support expression which as has both double and int. Operation: '" + arithmeticOperator + "' \n" + debugMessage;
               yyerror(errorMessage.c_str());
               return;
          } 
          // (symbol vs value)
          else if((typeFromSymbol1 != LexemType::Unknown && typeFromSymbol2 == LexemType::Unknown) && (!CheckTypeConsistency(typeFromSymbol1, second->_type)))
          {
               std::string debugMessage = "First: " + std::to_string(typeFromSymbol1) + "| Second:" + second->GetValueAndTypeAsMessage();
               std::string errorMessage = "Goodii language <" + _langVersion + "> does not support expression which as has both double and int. Operation: '" + arithmeticOperator + "' \n" + debugMessage;
               yyerror(errorMessage.c_str());
               return;
          }   
          // (value vs symbol)
          else if((typeFromSymbol1 == LexemType::Unknown && typeFromSymbol2 != LexemType::Unknown) && (!CheckTypeConsistency(first->_type, typeFromSymbol2)))
          {
               std::string debugMessage = "First: " + first->GetValueAndTypeAsMessage() + "| Second:" + std::to_string(typeFromSymbol2);
               std::string errorMessage = "Goodii language <" + _langVersion + "> does not support expression which as has both double and int. Operation: '" + arithmeticOperator + "' \n" + debugMessage;
               yyerror(errorMessage.c_str());
               return;
          }
     }

public:

     GrammaBuilder(FileAppender* triplesOutputFileAppender, FileAppender* assemblerOutputFileAppender){
          _allTextElementsStack = new std::stack<TextElement*>();
          _assemblerOutputCode = new std::vector<std::string>();
          _triplesOutputFileAppender = triplesOutputFileAppender;
          _assemblerOutputFileAppender = assemblerOutputFileAppender;
          _symbols = new std::map<std::string, TextElement*>();
          ResetOutput();
     }

     void ResetOutput()
     {
          _triplesOutputFileAppender->tryClean();
          _assemblerOutputFileAppender->tryClean();
     }

     void GenerateAssemblerDataBlock()
     {
          _assemblerOutputFileAppender->append(".data \n", false);

               std::map<std::string, TextElement*>::iterator it;
               for (it = _symbols->begin(); it != _symbols->end(); it++)
               {
                         if(it->second->_type == LexemType::Integer)
                         {
                              std::string integerDeclaration = it->second->_value + ": .word   " + Constants::IntegerTypeDefaultValue + "\n";
                              _assemblerOutputFileAppender->append(integerDeclaration, false);
                         }
                         else if(it->second->_type == LexemType::Double)
                         {
                              //TODO:
                         }
               }
     }

     void GenerateAssemblerInstructions()
     {    
          _assemblerOutputFileAppender->append(".text \n", false);
          for(int i = 0; i < _assemblerOutputCode->size(); i++)
          {
               std::string assemblerLine = _assemblerOutputCode->at(i);
               _assemblerOutputFileAppender->append(assemblerLine + "\n", false);
          }
     }

     void InsertSymbol(LexemType type, std::string value)
     {
          TextElement* intSymbol = new TextElement(type, value);
          std::pair<std::string, TextElement*> pair = std::make_pair(intSymbol->_value, intSymbol);
           _symbols->insert(pair);
     }

     void PushGoodii(TextElement *element)
     {
          std::cout << "GrammarBuilder::Pushing val<" << element->_value << "> type<" << element->_type << "> \n";
          if(_allTextElementsStack->size() > 0)
          {
               _beforeTopElement = _allTextElementsStack->top();
          }
          _allTextElementsStack->push(element);
     }

     std::string BuildCommentFromLastTwo(std::string concatenator)
     {
          std::string commentedResult;
          if(_beforeTopElement)
          {
               commentedResult = "#" + _beforeTopElement->_value + concatenator + _allTextElementsStack->top()->_value;
          }
          else
          {
               commentedResult = "#" + concatenator + _allTextElementsStack->top()->_value;
          }
          _assemblerOutputCode->push_back(commentedResult);
          return commentedResult;
     }

     void BuildTriples(std::string arithmeticOperator)
     {
          //std::cout << "GrammaBuilder::BuildTriples. No. of call: ((" << UniqueIdGenerator::GetNextUniqueInvocationCounter() << "x))" << std::endl;

          TextElement* second = GetAndRemove();
          TextElement* first = GetAndRemove();
          std::string result = GenerateTripleResultString(arithmeticOperator, first, second);

          std::string numberedResult = GetResultStringWithId();
          TextElement* resultVariable = new TextElement(LexemType::Txt, numberedResult);
          PushGoodii(resultVariable);

          _assemblerOutputCode->push_back("#" + result);

          LexemType typeFromSymbol1 = LexemType::Unknown;
          LexemType typeFromSymbol2 = LexemType::Unknown;

          if(_symbols->size() > 0 )
          {
               if(first->_type == LexemType::Txt)
               {
                    if(_symbols->count(first->_value))
                    {
                         std::cout << "Debug::Key succesfully found <" << first->_value << ">";
                         TextElement* foundSymbol = _symbols->find(first->_value)->second;
                         typeFromSymbol1 = foundSymbol->_type;
                    }
                    else
                    {
                         std::cout << "Debug::Key not found<" << first->_value << ">";
                    }
               }

               if(second->_type == LexemType::Txt)
               {
                    if(_symbols->count(second->_value))
                    {
                         std::cout << "Debug::Key succesfully found <" << second->_value << ">";
                         TextElement* foundSymbol = _symbols->find(second->_value)->second;
                         typeFromSymbol2 = foundSymbol->_type;
                    }
                    else
                    {
                         std::cout << "Debug::Key not found<" << second->_value << ">";
                    }
               }
          }


          ExecuteTypeValidation(first, second, typeFromSymbol1, typeFromSymbol2, arithmeticOperator);

          //Handling Assignments - assembler code generation ($t0)
          switch(first->_type)
          {
               case LexemType::Txt:
               {
                    std::string assemblerLineTxt = "lw $t0, " + first->_value;
                    _assemblerOutputCode->push_back(assemblerLineTxt);
                    break;
               }
               case LexemType::Integer:
               {
                    std::string assemblerLineInt = "li $t0, " + first->_value;
                    _assemblerOutputCode->push_back(assemblerLineInt);
                    break;
               }
               case LexemType::Double:
               {
                    //TODO
                    break;
               }
               
          }

          //Handling Assignments - assembler code generation ($t1)
          switch(second->_type)
          {
               case LexemType::Txt:
               {               
                    std::string assemblerLineTxt = "lw $t1, " + second->_value;
                    _assemblerOutputCode->push_back(assemblerLineTxt);
                    break;
               }
               case LexemType::Integer:
               {
                    std::string assemblerLineInt = "li $t1, " + second->_value;
                    _assemblerOutputCode->push_back(assemblerLineInt);
                    break;
               }
               case LexemType::Double:
               {
                    //TODO
                    break;
               }
          }

          //Handling arithmetic operator - assembler code generation for integers ($t0 and $t1 operation into $t0)
         if(CanGenerateArithmeticForInts(first->_type, second->_type))
         {
               InsertSymbol(LexemType::Integer, numberedResult);
          	if(arithmeticOperator == Constants::Subtraction)
		     {    	
			     _assemblerOutputCode->push_back("sub $t0, $t0, $t1");
		     }
               else if(arithmeticOperator == Constants::Addition)
		     {	
			    _assemblerOutputCode->push_back("add $t0, $t0, $t1");
		     }
               else if(arithmeticOperator == Constants::Multiplication)
		     {	
			     _assemblerOutputCode->push_back("mul $t0, $t0, $t1");
		     }
               else if(arithmeticOperator == Constants::Subtraction)
		     {	
			     _assemblerOutputCode->push_back("div $t0, $t0, $t1");
		     }
               _assemblerOutputCode->push_back("sw $t0, " + numberedResult + "\n");
         }
         //Handling arithmetic operator - assembler code generation for doubles ($f0 and $f1 operation into $f0)
         else if (CanGenerateArithmeticForDoubles(first->_type, second->_type))
         {
              InsertSymbol(LexemType::Double, numberedResult);
          	if(arithmeticOperator == Constants::Subtraction)
		     {    	
			     _assemblerOutputCode->push_back("sub.s $f0, $f0, $f1");
		     }
               else if(arithmeticOperator == Constants::Addition)
		     {	
			    _assemblerOutputCode->push_back("add.s $f0, $f0, $f1");
		     }
               else if(arithmeticOperator == Constants::Multiplication)
		     {	
			     _assemblerOutputCode->push_back("mul.s $f0, $f0, $f1");
		     }
               else if(arithmeticOperator == Constants::Subtraction)
		     {	
			     _assemblerOutputCode->push_back("div.s $f0, $f0, $f1");
		     }
               _assemblerOutputCode->push_back("s.s $f0  , " + numberedResult + "\n");
         }

      _triplesOutputFileAppender->append(result, true); 
     }

};

FileAppender *triplesOutputFileAppender = new FileAppender("triples_goodii.txt");
FileAppender *assemblerOutputFileAppender = new FileAppender("outputCode.asm");
GrammaBuilder *builder = new GrammaBuilder(triplesOutputFileAppender, assemblerOutputFileAppender);

%}

%union 
{
	char *textIdentifier;
	int	integerValue;
     double decimalValue;
};

/** Tokens **/

%start lines;
%right '='
%left '+' '-'
%left '*'

/** Tokens **/
%token INT DOUBLE STRINGI BOOLEAN;
%token IF ELSE WHILE RETURN;
%token READ PRINT;
%token TRUE FALSE COMMENT;
%token EQ NEQ GEQ LEQ;

%token<textIdentifier> TEXT_IDENTIFIER;
%token<integerValue> VALUE_INTEGER;
%token<decimalValue> VALUE_DECIMAL;

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
       components '+' expression {  printf("Syntax-Recognized: dodawanie\n"); builder->BuildTriples(Constants::Addition); }
	| components '-' expression {  printf("Syntax-Recognized: odejmowanie\n"); builder->BuildTriples(Constants::Subtraction); }
	| components
	;

components:
	  components '*' elementCmp {  printf("Syntax-Recognized: mnozenie\n"); builder->BuildTriples(Constants::Multiplication); }
	| components '/' elementCmp {  printf("Syntax-Recognized: dzielenie\n"); builder->BuildTriples(Constants::Subtraction); }
	| elementCmp                 {  printf("(konkretnaWartosc)\n"); }
	;

elementCmp:
	  VALUE_INTEGER			{  printf("Syntax-Recognized: wartosc calkowita\n");          builder->PushGoodii(new TextElement(LexemType::Integer, std::to_string($1))); }
	| VALUE_DECIMAL			{  printf("Syntax-Recognized: wartosc zmiennoprzecinkowa\n"); builder->PushGoodii(new TextElement(LexemType::Double, std::to_string($1)));  }
     | TEXT_IDENTIFIER                        {  printf("Syntax-Recognized: text-zmn\n");                   builder->PushGoodii(new TextElement(LexemType::Txt, std::string($1))); }
	;

%%

int main (int argc, char *argv[]) 
{
     
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

     builder->GenerateAssemblerDataBlock();
     builder->GenerateAssemblerInstructions();
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
