# Goodii Language Specification

# Contents

[**Goodii Language Specification** ]

[**Goodii Types** 2](#_Toc53317532)

[**Goodii Loops** 2](#_Toc53317533)

[**Goodii Decision making** 2](#_Toc53317534)

[**Goodii Relational operators** 2](#_Toc53317535)

[**Goodii Arithmetic operators** 2](#_Toc53317536)

[~~**Goodii Logical operators**~~ 3](#_Toc53317537)

[**Goodii keywords / literals** 3](#_Toc53317538)

[**Goodii literals** 3](#_Toc53317539)

[**Goodii Other lexems** 3](#_Toc53317540)

[**Goodii Arrays** 4](#_Toc53317541)

[**Examples** 5](#_Toc53317542)

## **Goodii Types**

| Name | Description |
| --- | --- |
| **intii** | 32-bit signed integer |
| **dublii** | 64-bit double precision floating point type |
| **stringii** | .. |
| **boolii** | Boolean value |

## **Goodii Loops**

| name | description |
| --- | --- |
| **whilii(_ condition _){ _//block of code_ }** | whilii can execute a block of code as long as condition is true. |



## **Goodii Decision making**

| name | description |
| --- | --- |
| **ifii** | Identifies if statement should be run. |
| **ifii( __condition__){ ****}**** elsii ****{**** }** | Identifies which statement to run based on value of condition |

## **Goodii Relational operators**

| operator | description |
| --- | --- |
| > | Checks if the value of left operand is greater than value of right operand |
| < | Checks if the value of left operand is less than value of right operand |
| => | Checks if the value of left operand is greater than or equal value of right operand |
| <= | Checks if the value of left operand is less than or equal value of right operand |

## **Goodii Arithmetic operators**

| operator | description |
| --- | --- |
| \|*\| | Multiplies both operands |
| \|/\| | Divides numerator by de-numerator |
| \|-\| | Substract second operand from the first |
| \|+\| | Adds two operands |
| \|==\| | Checks if two operands are equal. |
| \|!=\| | Checks if two operands are not equal |
| \|=\| | Assignment operator |
| \|++\| | Increment operator increases integer value by one |
| \|--\| | Decrement operator decreases integer value by one |

## ~~**Goodii Logical operators (not supported)**~~

| ~~!~~ | ~~Logical NOT operator.~~ |
| --- | --- |
| ~~&amp;&amp;~~ | ~~Logical AND operator.~~ |
| ~~||~~ | ~~Logical OR operator.~~ |

##

## **Goodii keywords / literals**
| name | description |
| --- | --- |
| **returnii** | Finishes the execution. |

## **Goodii literals**

| name | description |
| --- | --- |
| **goodii** | Means that is true |
| **badii** | Means that it is false |
| **nullii** | Null reference, doesn&#39;t refer to any object. |

## **Goodii Other lexems**

| **Escape sequence** | **Meaning** |
| --- | --- |
| ( | Left bracket |
| ) | Left brace |
| [ | Right bracket |
| ] | Right Bracket |
| ; | End of expression |
| \t | New tab |
| \n | New Line |
| // | Comment |

## **Goodii Arrays**

Declaration of arrays with length = 5.

**intiiGoodies[5]** arrayOfInts;

**dubliGoodies[5]** arrayOfDoubles;

**stringiGoodies[5]** arrayOfStrings;



## **Goodii Input/Output **
| name | description |
| --- | --- |
| **Printi(**_ **value as texti** _**)** | Printing **stringii** value to output stream. |
| **Printi** _**(value as intii)**_ | Printing **intii** value to output stream. |
| **Input** _**(value as stringii)**_ | Reading **stringii** value from input stream and returns **stringii**. |
| **Input** _**(value as intii)**_ | Reading **intii** value from input stream and returns **intii**. |

## **Goodii Input/Output**

## **Examples**

![](RackMultipart20201016-4-11zhb6b_html_9c5b6a5a0cb7d6b9.png)
