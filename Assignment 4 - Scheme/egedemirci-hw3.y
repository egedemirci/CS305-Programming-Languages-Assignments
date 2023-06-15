%{
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>	
#include <string.h>
#include "egedemircihw3.h"

void yyerror (const char *s) 
{}

struct printerNode * dummyNode;
struct printerNode *head = NULL;
int counter = 0;
struct printerNode * ptr;

%}

%union {
NumericNode NumericNode;
char * stringValue;
ExprNode ExprNode;
int lineNumber;
}


%token   tPRINT tGET tSET tFUNCTION tRETURN tIDENT tEQUALITY tIF tGT tLT tGEQ tLEQ tINC tDEC

%token <lineNumber> tADD tSUB tMUL tDIV
%token <stringValue> tSTRING
%token <NumericNode> tNUM
%type <ExprNode> operation
%type <ExprNode> expr


%start prog

%%
prog:		'[' stmtlst ']'  
;

stmtlst:	stmtlst stmt |
;

stmt:		setStmt | 
			if | 
			print | 
			unaryOperation | 
			expr {insertNode($1,0); } | 
			returnStmt
;

getExpr:	'[' tGET ',' tIDENT ',' '[' exprList ']' ']'
		| '[' tGET ',' tIDENT ',' '[' ']' ']'
		| '[' tGET ',' tIDENT ']'
;

setStmt:	'[' tSET ',' tIDENT ',' expr ']' {insertNode( $6,0); }
;

if:		'[' tIF ',' condition ',' '[' stmtlst ']' ']'
		| '[' tIF ',' condition ',' '[' stmtlst ']' '[' stmtlst ']' ']'
;

print:		'[' tPRINT ',' expr ']' {insertNode($4,0); }
;

operation:	'[' tADD ',' expr ',' expr ']' {$$ = mkAddition(&($4), &($6), $2);}
		| '[' tSUB ',' expr ',' expr ']' {$$ = mkSubs(&($4), &($6), $2);}
		| '[' tMUL ',' expr ',' expr ']' {$$ = mkMultip(&($4), &($6), $2);}
		| '[' tDIV ',' expr ',' expr ']' {$$ = mkDivis(&($4), &($6), $2);}
;	

unaryOperation: '[' tINC ',' tIDENT ']'
		| '[' tDEC ',' tIDENT ']'
;

expr:		tNUM  {$$ = Numer($1, 0, 0);} | 
			tSTRING {$$ = String($1,0,0);}| 
			getExpr {$$ = dummyExp();} |  
			function {$$ = dummyExp();}| 
			operation | 
			condition {$$ = dummyExp();}
;

function:	 '[' tFUNCTION ',' '[' parametersList ']' ',' '[' stmtlst ']' ']'
		| '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
;

condition:	'[' tEQUALITY ',' expr ',' expr ']' {insertNode( $4,0); insertNode( $6,0); }
		| '[' tGT ',' expr ',' expr ']' {insertNode($4,0); insertNode($6,0); }
		| '[' tLT ',' expr ',' expr ']' {insertNode($4,0); insertNode($6,0); }
		| '[' tGEQ ',' expr ',' expr ']' {insertNode( $4,0); insertNode( $6,0); }
		| '[' tLEQ ',' expr ',' expr ']' {insertNode($4,0); insertNode( $6,0); }
;

returnStmt:	'[' tRETURN ',' expr ']' {insertNode($4,0);}
		| '[' tRETURN ']'
;

parametersList: parametersList ',' tIDENT | tIDENT
;

exprList:	exprList ',' expr  {insertNode($3,0);}| 
			expr {insertNode($1,0);}
;
%%

void insertNode(ExprNode expr, bool misMatch){
	if (head == NULL)
	{
		struct printerNode * new_node = (struct printerNode*) malloc(sizeof(printerNode));
		new_node->isMismatch = misMatch;
		new_node->exprNode = expr;
		new_node->lineNumber = expr.lineNumber;
		head = new_node;
		head->next = NULL;
	}
	else
	{
		ptr = head; 
		while (ptr->next != NULL){
			ptr = ptr->next;
		}		
		struct printerNode * new_node = (struct printerNode*) malloc(sizeof(printerNode));
		new_node->isMismatch = misMatch;
		new_node->exprNode = expr;
		new_node->lineNumber = expr.lineNumber;
		new_node->next = NULL;
		ptr->next = new_node;
	}
}


ExprNode String(char * strVal, bool willPrinted, int lineNo) {
	ExprNode newString;
	newString.type = string;
	newString.lineNumber = lineNo;
	newString.stringValue = strVal;
	newString.willPrinted = willPrinted;
	return (newString);
}

ExprNode Numer(NumericNode num, bool willPrinted, int lineNo){
	ExprNode newNum;
	newNum.type = numeric;
	newNum.lineNumber = lineNo;
	newNum.numericNode.isReal = num.isReal;
	newNum.numericNode.realValue = num.realValue;
	newNum.willPrinted = willPrinted;
	return (newNum);
}

ExprNode dummyExp() {
	ExprNode dummyResult;
    dummyResult.type = NOTBOTH;
    return dummyResult;
}

ExprNode mkAddition( ExprNode * first ,  ExprNode * second, int lineNo){
	if( first->type == numeric && second->type == numeric){
		if(first->numericNode.isReal == 0 && second->numericNode.isReal == 0){
			first->willPrinted = 0;
			second->willPrinted = 0;
			NumericNode result;
			result.realValue = first->numericNode.realValue + second->numericNode.realValue;
			result.isReal = 0;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
		else if(first->numericNode.isReal == 1 || second->numericNode.isReal == 1){
			first->willPrinted = 0;
			second->willPrinted = 0;
			NumericNode result;
			result.realValue = first->numericNode.realValue + second->numericNode.realValue;
			result.isReal = 1;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
	}
	else if( first->type == string && second->type == string){
			first->willPrinted = 0;
			second->willPrinted = 0;
		    char *firstStr = first->stringValue;
    		char *secondStr = second->stringValue;
    		char *result = (char*) malloc(strlen(firstStr) + strlen(secondStr) + 1);
			strcpy(result, firstStr);   
			strcat(result, secondStr); 
			insertNode(*first,0);
			insertNode(*second,0);
			return String(result,1,lineNo);
 
	}

	else if((first->type == numeric && second->type == string) || (first->type == string && second->type == numeric)){
		ExprNode mismatchNode;
		mismatchNode.lineNumber = lineNo;
		mismatchNode.type = NOTBOTH;
		insertNode( mismatchNode, 1);
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();
	}
	else{ 		
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();

	}}

ExprNode mkSubs(ExprNode * first , ExprNode * second, int lineNo){
	if( first->type == numeric && second->type == numeric){
		if(first->numericNode.isReal == 0 && second->numericNode.isReal == 0){
			NumericNode result;
			first->willPrinted = 0;
			second->willPrinted = 0;
			result.realValue = first->numericNode.realValue - second->numericNode.realValue;
			result.isReal = 0;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
		else if(first->numericNode.isReal == 1 || second->numericNode.isReal == 1){
			NumericNode result;
			first->willPrinted = 0;
			second->willPrinted = 0;
			result.realValue = first->numericNode.realValue - second->numericNode.realValue;
			result.isReal = 1;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
	}
	else if((first->type == numeric && second->type == string) || (first->type == string && second->type == numeric) || (first->type == string && second->type == string)){
		ExprNode mismatchNode;
		mismatchNode.lineNumber = lineNo;
		mismatchNode.type = NOTBOTH;
		insertNode(mismatchNode, 1);
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
 		return dummyExp();
	}
	else{
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
	return dummyExp();

	}
}

ExprNode mkMultip(ExprNode * first , ExprNode * second, int lineNo){
	if( first->type == numeric && second->type == numeric){
		if(first->numericNode.isReal == 0 && second->numericNode.isReal == 0){
			NumericNode result;
			first->willPrinted = 0;
			second->willPrinted = 0;
			result.realValue = first->numericNode.realValue * second->numericNode.realValue;
			result.isReal = 0;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
		else if(first->numericNode.isReal == 1 || second->numericNode.isReal == 1){
			NumericNode result;
			first->willPrinted = 0;
			second->willPrinted = 0;
			result.realValue = first->numericNode.realValue * second->numericNode.realValue;
			result.isReal = 1;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
	}
	else if( first->type == numeric && second->type == string){
		if(first->numericNode.isReal == 0 && first->numericNode.realValue > 0){
			first->willPrinted = 0;
			second->willPrinted = 0;
			char * secondtStr = second->stringValue;
			char* result = (char*) malloc((strlen(secondtStr) *  first->numericNode.realValue)+ 1); // allocate memory for the result string
			strcpy(result, ""); // initialize the result string to an empty string
			int i;
			for (i = 0; i < first->numericNode.realValue; i++) {
				strcat(result, secondtStr); // concatenate the input string to the result string
			}
			insertNode(*first,0);
			insertNode(*second,0);
			return String(result,1,lineNo);
		}
		else if(first->numericNode.isReal == 0 && first->numericNode.realValue == 0){
			first->willPrinted = 0;
			second->willPrinted = 0;
			char * secondtStr = second->stringValue;
			char* result = (char*) malloc((strlen(secondtStr) * first->numericNode.realValue)+ 1); // allocate memory for the result string
			strcpy(result, ""); // initialize the result string to an empty string
			insertNode(*first,0);
			insertNode(*second,0);
			return String(result,1,lineNo);
		}
		else{
				ExprNode mismatchNode;
				mismatchNode.lineNumber = lineNo;
				mismatchNode.type = NOTBOTH;
				insertNode(mismatchNode, 1);
				if(first->type != NOTBOTH){
					insertNode(*first,0);
				}
				if(second->type != NOTBOTH){
					insertNode(*second,0);
				}
				return dummyExp();
		}
	}
	else if ((first->type == string && second->type == numeric) || (first->type == string && second->type == string) || (first->type == string && second->type == string)){
		ExprNode mismatchNode;
		mismatchNode.lineNumber = lineNo;
		mismatchNode.type = NOTBOTH;
		insertNode( mismatchNode, 1);
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();
	}
	else{
				if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();

	}
}

ExprNode mkDivis(ExprNode * first , ExprNode * second, int lineNo){
	if( first->type == numeric && second->type == numeric){
		if(first->numericNode.isReal == 0 && second->numericNode.isReal == 0){
			first->willPrinted = 0;
			second->willPrinted = 0;
			NumericNode result;
			result.realValue = (int)first->numericNode.realValue / (int)second->numericNode.realValue;
			result.isReal = 0;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
		else if(first->numericNode.isReal == 1 || second->numericNode.isReal == 1){
			NumericNode result;
			first->willPrinted = 0;
			second->willPrinted = 0;
			result.realValue = first->numericNode.realValue / second->numericNode.realValue;
			result.isReal = 1;
			insertNode(*first,0);
			insertNode(*second,0);
			return Numer(result,1,lineNo);
		}
	}
	else if((first->type == numeric && second->type == string) || (first->type == string && second->type == numeric) || (first->type == string && second->type == string)){
		ExprNode mismatchNode;
		mismatchNode.lineNumber = lineNo;
		mismatchNode.type = NOTBOTH;
		insertNode(mismatchNode, 1);
				if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();

	}
	else{
		if(first->type != NOTBOTH){
			insertNode(*first,0);
		}
 		if(second->type != NOTBOTH){
			insertNode(*second,0);
		}
		return dummyExp();
	}

}

void printTree (){
	struct printerNode * ptr;
	ptr = head;
	ExprNode node;
	while (ptr != NULL){
		node = ptr->exprNode;
		int lineNo = ptr->lineNumber;
		bool mismatch = ptr->isMismatch;
		if (mismatch == 1){
			printf("Type mismatch on %d\n", lineNo);
		}	
		else if (mismatch == 0 && node.willPrinted == 1){
			if(node.type == numeric && node.numericNode.isReal == 1){
				double finalRes = 0;
				int integer_part;
				if (node.numericNode.realValue > 0){ 
					integer_part = (int)(node.numericNode.realValue * 10 + 0.5);
					finalRes = integer_part / 10.0;
				}
				else if (node.numericNode.realValue < 0){ 
				    integer_part = (int)(node.numericNode.realValue * 10 - 0.5);
					finalRes = integer_part / 10.0;
				}
            	printf("Result of expression on %d is (%.1f)\n", lineNo, finalRes);
			}
			else if(node.type == numeric && node.numericNode.isReal == 0){
            	printf("Result of expression on %d is (%d)\n", lineNo,  (int)node.numericNode.realValue);
			}
			else if(node.type == string){
            	printf("Result of expression on %d is (%s)\n", lineNo,  node.stringValue);
			}
		}
		ptr = ptr->next;
	}
}
 
int main ()
{
	printerNode *head = malloc(sizeof(printerNode));
	head->next = NULL;
	ExprNode emptyNode;
	head->exprNode = emptyNode;
	if (yyparse()) {
	// parse error
		printf("ERROR\n");
		return 1;
	}
	else {
	// successful parsing
	printTree();
	return 0;
	}
}
