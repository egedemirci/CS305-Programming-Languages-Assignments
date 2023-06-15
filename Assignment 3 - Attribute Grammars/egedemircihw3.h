#ifndef __HW3_H
#define __HW3_H
#include <stdio.h>
#include <stdbool.h>

typedef enum { string, numeric, NOTBOTH} ExprType;

typedef struct NumericNode{
    bool isReal;
    double realValue;
} NumericNode;

typedef struct ExprNode
{
    ExprType type;
    int lineNumber;
    NumericNode numericNode;
    char * stringValue;
    bool willPrinted;
} ExprNode;

typedef struct printerNode
{
    int lineNumber;
	struct printerNode *next;
	bool isMismatch;
    ExprNode exprNode;
} printerNode;

ExprNode String(char * strVal, bool willPrinted, int lineNo);
ExprNode Numer(NumericNode num, bool willPrinted, int lineNo);
ExprNode dummyExp();
ExprNode mkAddition(ExprNode * first , ExprNode * sec, int lineNo);
ExprNode mkMultip(ExprNode * first , ExprNode * sec, int lineNo);
ExprNode mkSubs(ExprNode * first , ExprNode * sec, int lineNo);
ExprNode mkDivis(ExprNode * first , ExprNode * sec, int lineNo);
printerNode * firstNode;
void printTree();
void insertNode(ExprNode expr, bool misMatch);
void insertFinalTree(ExprNode expr, bool misMatch);

#endif
