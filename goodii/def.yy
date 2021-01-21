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
     std::string DoubleTypeDefaultValue = "0";
     std::string Temporary = "temp";
}

class UniqueIdGenerator
{

     static int resultCounter;
     static int triplesInvocationCounter;
     static int temporaryVarCounter;

     public:

     static int GetNextUniqueResult()
     {
          return ++resultCounter;
     }

     static int GetNextUniqueInvocationCounter()
     {
          return ++triplesInvocationCounter;
     }

     static int GetNextUniqueTemporaryVar()
     {
          return ++temporaryVarCounter;
     }

};

int UniqueIdGenerator::resultCounter = 0;
int UniqueIdGenerator::triplesInvocationCounter = 0;
int UniqueIdGenerator::temporaryVarCounter = 0;

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

enum TripleType
{
     Undefined,
     SymbolAndSymbol,
     ValueAndValue,
     SymbolAndValue,
     ValueAndSymbol
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
		LexemType _type;
          // could be integer: 1 or double 1.0 or literal. For doubles, _value is a literal.
		std::string _value;

          // used only for LexemType::Double only!
          std::string _optionalDoubleValue;


     TextElement(LexemType type, std::string value, std::string optionalDoubleValue = "0")
     {
          _value = value;
          _type = type;
          _optionalDoubleValue = optionalDoubleValue;
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

     std::string GetTempStringWithId()
     {
          int nextId = UniqueIdGenerator::GetNextUniqueTemporaryVar();
          return Constants::Temporary + "_" + std::to_string(nextId);
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


     TripleType GetTripleType(LexemType typeFromSymbol1, LexemType typeFromSymbol2)
     {
          if(typeFromSymbol1 != LexemType::Unknown && typeFromSymbol2 != LexemType::Unknown)
          {
               return TripleType::SymbolAndSymbol;
          }
          else if(typeFromSymbol1 == LexemType::Unknown && typeFromSymbol2 == LexemType::Unknown)
          {
               return TripleType::ValueAndValue;
          }
          else if(typeFromSymbol1 != LexemType::Unknown && typeFromSymbol2 == LexemType::Unknown)
          {
               return TripleType::SymbolAndValue;
          }
          else if(typeFromSymbol1 == LexemType::Unknown && typeFromSymbol2 != LexemType::Unknown)
          {
               return TripleType::ValueAndSymbol;
          }
          return TripleType::Undefined;
     }

     std::pair<LexemType, LexemType> GetProcessedTypes(TripleType tripleType, TextElement* first, TextElement* second, LexemType typeFromSymbol1, LexemType typeFromSymbol2)
     {
          switch(tripleType)
          {
               case TripleType::SymbolAndSymbol:
               {
                    return std::pair<LexemType, LexemType>(typeFromSymbol1, typeFromSymbol2);
               }
               case TripleType::ValueAndValue:
               {
                    return std::pair<LexemType, LexemType>(first->_type, second->_type);
               }
               case TripleType::SymbolAndValue:
               {
                    return std::pair<LexemType, LexemType>(typeFromSymbol1, second->_type);
               }  
               case TripleType::ValueAndSymbol:
               {
                    return std::pair<LexemType, LexemType>(first->_type, typeFromSymbol2);
               }
               case TripleType::Undefined:
               {
                    std::string errorMessage = "Undefined error occured during the verification of processed types.";
                    yyerror(errorMessage.c_str());
                    break;
               }
          }
          return std::pair<LexemType, LexemType>(LexemType::Unknown, LexemType::Unknown);
     }

     void GenerateAssignmentCodeAssembler(LexemType first, LexemType second)
     {
     }

     void ExecuteTypeValidation(TripleType tripleType, LexemType processedType1, LexemType processedType2, std::string arithmeticOperator)
     {
           if((!CheckTypeConsistency(processedType1, processedType2)))
           {
                    std::string debugMessage = "First:" + std::to_string(processedType1) + "| Second:" + std::to_string(processedType2);
                     std::string errorMessage = "Goodii language <" + _langVersion + "> does not support expression which as has both double and int. Operation: '" + arithmeticOperator + "' \n" + debugMessage;
                    yyerror(errorMessage.c_str());
                    return;
          } 
     }
     
     void GenerateAssignmentCodeForAssembler(LexemType type, std::string value, std::string registryName)
     {
          switch(type)
          {
               case LexemType::Txt:
               {
                    std::string assemblerLineTxt = "lw " + registryName + ", " + value;
                    _assemblerOutputCode->push_back(assemblerLineTxt);
                    break;
               }
               case LexemType::Integer:
               {
                    std::string assemblerLineInt = "li " + registryName + ", " + value;
                    _assemblerOutputCode->push_back(assemblerLineInt);
                    break;
               }
               case LexemType::Double:
               {
                    std::string assemblerLineTxt = "l.s " + registryName + ", " + value;
                    _assemblerOutputCode->push_back(assemblerLineTxt);
                    break;
               }
               
          }
     }

     //sub $t0, $t0, $t1
     //add $t0, $t0, $t1
     //mul $t0, $t0, $t1
     //div $t0, $t0, $t1
     //sw $t0, result10
     void GenerateArithmeticOperationIntegersForAssembler(std::string arithmeticOperator, std::string reg1, std::string reg2, 
                                                         std::string operationResultRegistry, std::string finalLabel)
     {
               std::string arithmeticOperationCode;
               if(arithmeticOperator == Constants::Subtraction)
		     {    
                    arithmeticOperationCode = "sub";
		     }
               else if(arithmeticOperator == Constants::Addition)
		     {	
                    arithmeticOperationCode = "add";
		     }
               else if(arithmeticOperator == Constants::Multiplication)
		     {	
                    arithmeticOperationCode = "mul";
		     }
               else if(arithmeticOperator == Constants::Subtraction)
		     {	
                    arithmeticOperationCode = "div";
		     }
               arithmeticOperationCode = arithmeticOperationCode + " " + operationResultRegistry + ", " + reg1 + ", " + reg2;
               _assemblerOutputCode->push_back(arithmeticOperationCode);
               _assemblerOutputCode->push_back("sw " + operationResultRegistry + ", " + finalLabel + "\n");
     }

     //sub.s $f0, $f0, $f1
     //add.s $f0, $f0, $f1
     //mul.s $f0, $f0, $f1
     //div.s $f0, $f0, $f1
     //s.s $f0, result10
     void GenerateArithmeticOperationDoublesForAssembler(std::string arithmeticOperator, std::string reg1, std::string reg2, 
                                                         std::string operationResultRegistry, std::string finalLabel)
     {
               std::string arithmeticOperationCode;
               if(arithmeticOperator == Constants::Subtraction)
		     {    
                    arithmeticOperationCode = "sub.s";
		     }
               else if(arithmeticOperator == Constants::Addition)
		     {	
                    arithmeticOperationCode = "add.s";
		     }
               else if(arithmeticOperator == Constants::Multiplication)
		     {	
                    arithmeticOperationCode = "mul.s";
		     }
               else if(arithmeticOperator == Constants::Subtraction)
		     {	
                    arithmeticOperationCode = "div.s";
		     }
               arithmeticOperationCode = arithmeticOperationCode + " " + operationResultRegistry + ", " + reg1 + ", " + reg2;
               _assemblerOutputCode->push_back(arithmeticOperationCode);
               _assemblerOutputCode->push_back("s.s " + operationResultRegistry + ", " + finalLabel + "\n");
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
                              std::string doubleDeclaration = it->second->_value + ": .float   " + it->second->_optionalDoubleValue + "\n";
                              _assemblerOutputFileAppender->append(doubleDeclaration, false);
                         }
               }
     }

     void GenerateAssemblerInstructions()
     {    
          _assemblerOutputFileAppender->append("\n.text\n", false);
          for(int i = 0; i < _assemblerOutputCode->size(); i++)
          {
               std::string assemblerLine = _assemblerOutputCode->at(i);
               _assemblerOutputFileAppender->append(assemblerLine + "\n", false);
          }
     }

     void InsertSymbol(LexemType type, std::string value, std::string optionalDoubleValue = "0")
     {
          TextElement* symbol = new TextElement(type, value, optionalDoubleValue);
          std::pair<std::string, TextElement*> pair = std::make_pair(symbol->_value, symbol);
           _symbols->insert(pair);
     }

     void PushGoodiiElement(TextElement *element)
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
          PushGoodiiElement(resultVariable);

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

          TripleType tripleType = GetTripleType(typeFromSymbol1, typeFromSymbol2);
          std::pair<LexemType, LexemType> processedTypes = GetProcessedTypes(tripleType, first, second, typeFromSymbol1, typeFromSymbol2);
          ExecuteTypeValidation(tripleType, processedTypes.first, processedTypes.second, arithmeticOperator);

          if(processedTypes.first == LexemType::Integer && processedTypes.second == LexemType::Integer)
          {
                    GenerateAssignmentCodeForAssembler(first->_type, first->_value, "$t0");
                    GenerateAssignmentCodeForAssembler(second->_type, second->_value, "$t1"); 
          }
          else if(processedTypes.first == LexemType::Double && processedTypes.second == LexemType::Double)
          {
               std::string defaultValue1 = Constants::DoubleTypeDefaultValue;
               if(first->_type != LexemType::Txt)
               {
                    defaultValue1 = first->_value;
               }

               std::string tempStringLabel1 = GetTempStringWithId();
               InsertSymbol(LexemType::Double, tempStringLabel1, defaultValue1);
               GenerateAssignmentCodeForAssembler(processedTypes.second, tempStringLabel1, "$f0");

               std::string defaultValue2 = Constants::DoubleTypeDefaultValue;
               if(second->_type != LexemType::Txt)
               {
                    defaultValue2 = second->_value;
               }

               std::string tempStringLabel2 = GetTempStringWithId();
               InsertSymbol(LexemType::Double, tempStringLabel2, defaultValue2);
               GenerateAssignmentCodeForAssembler(processedTypes.second, tempStringLabel2, "$f1");
          }

         if(CanGenerateArithmeticForInts(first->_type, second->_type))
         {
               InsertSymbol(LexemType::Integer, numberedResult);
               GenerateArithmeticOperationIntegersForAssembler(arithmeticOperator, "$t0", "$t1", "$t0", numberedResult);
         }
         else if (CanGenerateArithmeticForDoubles(first->_type, second->_type))
         {
              InsertSymbol(LexemType::Double, numberedResult);
              GenerateArithmeticOperationDoublesForAssembler(arithmeticOperator, "$f0", "$f1", "$f0", numberedResult);
         }

      _triplesOutputFileAppender->append(result, true); 
     }

     void BuildPrinting()
     {
          LexemType topElementType = _allTextElementsStack->top()->_type;

          switch(topElementType)
          {
               case LexemType::Integer:
               {
                    std::string value = _allTextElementsStack->top()->_value;
                    GenerateAssemblerToPrintInteger(value);
                    break;
               }
               case LexemType::Double:
               {
                    std::string value = _allTextElementsStack->top()->_value;
                    std::string tempStringLabel = GetTempStringWithId();
                    InsertSymbol(LexemType::Double, tempStringLabel, value);
                    GenerateAssemblerToPrintDouble(tempStringLabel);
                    break;
               }
               case LexemType::Txt:
               {
                    LexemType typeFromSymbol;
                    if(_symbols->size() > 0)
                    {
                         std::string value = _allTextElementsStack->top()->_value;
                         if(_symbols->count(value))
                         {
                              std::cout << "BuildPrinting::Debug::Key succesfully found <" << value << ">";
                              TextElement* foundSymbol = _symbols->find(value)->second;
                              typeFromSymbol = foundSymbol->_type;

                              switch(typeFromSymbol)
                              {
                                   case LexemType::Integer:
                                   {
                                        std::string value = _allTextElementsStack->top()->_value;
                                        GenerateAssemblerToPrintInteger(value);
                                        break;
                                   }
                                   case LexemType::Double:
                                   {
                                        std::string value = _allTextElementsStack->top()->_value;
                                        GenerateAssemblerToPrintDouble(value);
                                   }
                              }
                         }
                         else
                         {
                              std::cout << "BuildPrinting::Debug::Key not found<" << value << ">";
                         }
                    }
                    else
                    {
                         std::cout << "Symbols are empty." << std::endl;
                    }
               }
          }
          _assemblerOutputCode->push_back("syscall");
     }

     void GenerateAssemblerToPrintInteger(std::string value)
     {
           _assemblerOutputCode->push_back("li $v0, 1");//integer to print
           _assemblerOutputCode->push_back("li $a0, " + value);
     }

     void GenerateAssemblerToPrintDouble(std::string value)
     {
          _assemblerOutputCode->push_back("li $v0, 2");//float to print
		_assemblerOutputCode->push_back("l.s $f12, " + value);
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
     | func ';'
     ;

expressionInBrackets:
     '(' expression ')'  {printf("Syntax-Recognized: wyrazenie w nawiasie \n");}
     ;

func:
     PRINT expressionInBrackets {printf("Syntax-Recognized: wyswietlenie wyrazenia w nawiasie \n"); builder->BuildPrinting();}
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
	  VALUE_INTEGER			{  printf("Syntax-Recognized: wartosc calkowita\n");          builder->PushGoodiiElement(new TextElement(LexemType::Integer, std::to_string($1))); }
	| VALUE_DECIMAL			{  printf("Syntax-Recognized: wartosc zmiennoprzecinkowa\n"); builder->PushGoodiiElement(new TextElement(LexemType::Double, std::to_string($1), std::to_string($1)));  }
     | TEXT_IDENTIFIER                        {  printf("Syntax-Recognized: text-zmn\n");        builder->PushGoodiiElement(new TextElement(LexemType::Txt, std::string($1))); }
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
