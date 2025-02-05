%{
#include <stdio.h>
#include "tokens.h"
int lineNo = 1;  // Defina a variável global lineNo
%}



// Tokens são definidos automaticamente pelo Bison em cminus.tab.h
%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token PLUS MINUS TIMES DIV
%token LT LTE GT GTE EQ NEQ
%token ASSIGN
%token SEMI COMMA
%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE

%%

program     : declaration_list
            ;

declaration_list
            : declaration_list declaration
            | declaration
            ;

declaration : var_declaration
            | fun_declaration
            ;

var_declaration
            : type_specifier ID SEMI
            | type_specifier ID LBRACK NUM RBRACK SEMI
            ;

type_specifier
            : INT
            | VOID
            ;

fun_declaration
            : type_specifier ID LPAREN params RPAREN compound_stmt
            ;

params      : param_list
            | VOID
            ;

param_list  : param_list COMMA param
            | param
            ;

param       : type_specifier ID
            | type_specifier ID LBRACK RBRACK
            ;

compound_stmt
            : LBRACE local_declarations statement_list RBRACE
            ;

local_declarations
            : local_declarations var_declaration
            | /* empty */
            ;

statement_list
            : statement_list statement
            | /* empty */
            ;

statement   : expression_stmt
            | compound_stmt
            | selection_stmt
            | iteration_stmt
            | return_stmt
            ;

expression_stmt
            : expression SEMI
            | SEMI
            ;

selection_stmt
            : IF LPAREN expression RPAREN statement
            | IF LPAREN expression RPAREN statement ELSE statement
            ;

iteration_stmt
            : WHILE LPAREN expression RPAREN statement
            ;

return_stmt : RETURN SEMI
            | RETURN expression SEMI
            ;

expression  : var ASSIGN expression
            | simple_expression
            ;

var         : ID
            | ID LBRACK expression RBRACK
            ;

simple_expression
            : additive_expression relop additive_expression
            | additive_expression
            ;

relop       : LTE
            | LT
            | GT
            | GTE
            | EQ
            | NEQ
            ;

additive_expression
            : additive_expression addop term
            | term
            ;

addop       : PLUS
            | MINUS
            ;

term        : term mulop factor
            | factor
            ;

mulop       : TIMES
            | DIV
            ;

factor      : LPAREN expression RPAREN
            | var
            | call
            | NUM
            ;

call        : ID LPAREN args RPAREN
            ;

args        : arg_list
            | /* empty */
            ;

arg_list    : arg_list COMMA expression
            | expression
            ;

%%

void yyerror(const char* s) {
    printf("Syntax error at line %d: %s\n", lineNo, s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();
    return 0;
}