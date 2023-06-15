/* C Declarations */
%{
    #include <stdio.h>
    void yyerror (const char *s) /* Called by yyparse on error */
    {
        return;
    }
%}

/* Bison Declarations */

%token tSTRING
%token tGET
%token tSET
%token tFUNCTION
%token tPRINT
%token tIF
%token tRETURN
%token tADD
%token tSUB
%token tMUL
%token tDIV
%token tINC
%token tGT
%token tEQUALITY
%token tDEC
%token tLT
%token tLEQ
%token tGEQ
%token tIDENT
%token tNUM

%% /* Grammar Rules and Actions */

program : '[' stmtlist ']' ;

stmtlist:   | 
            stmt stmtlist
        ;

stmt :      set | 
            if | 
            print | 
            increment | 
            decrement | 
            return | 
            expr
        ;

set :   '[' tSET ',' tIDENT ',' expr ']'
        ; 

if :    '[' tIF ',' condition ',' then ']' |
        '[' tIF ',' condition ',' then else ']'
        ;

then :  '[' stmtlist ']'
        ;

else :  '[' stmtlist ']'
        ;

print : '[' tPRINT ',' expr ']'
        ;

increment : '[' tINC ',' tIDENT ']'
            ;

decrement : '[' tDEC ',' tIDENT ']'
            ;


condition : '[' tGT ',' expr ',' expr ']' |
            '[' tLT ',' expr ',' expr ']' |
            '[' tLEQ ',' expr ',' expr ']' |
            '[' tGEQ ',' expr ',' expr ']' |
            '[' tEQUALITY ',' expr ',' expr ']' 
            ; 
    
expr :  tNUM |
        tSTRING |
        get  |
        function |
        operator |
        condition
        ;

exprlist:   expr | 
            expr ',' exprlist
        ;

get :   '[' tGET ',' tIDENT ']' |
        '[' tGET ',' tIDENT ',' '[' ']' ']' |
        '[' tGET ',' tIDENT ',' '[' exprlist ']' ']'
        ;


function :  '[' tFUNCTION ',' '[' paramlist ']' ',' '[' stmtlist ']' ']' |
            '[' tFUNCTION ',' '[' ']' ',' '[' stmtlist ']' ']'                
        ;

paramlist:  paramlist ',' tIDENT |
            tIDENT
        ;

operator :  '[' tADD ',' expr ',' expr ']' |
            '[' tSUB ',' expr ',' expr ']' |
            '[' tMUL ',' expr ',' expr ']' |
            '[' tDIV ',' expr ',' expr ']' 
        ;


return : '[' tRETURN ']' |
         '[' tRETURN ',' expr ']'
        ;


%% /* The main parser function */
int main ()
{
    if (yyparse()) {
        // Parse error
        printf("ERROR\n");
        return 1;
    }
    else {
        // Successful parsing
        printf("OK\n");
        return 0;
    }
}