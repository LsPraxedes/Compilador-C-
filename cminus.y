%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"

extern int yylex();
extern FILE* yyin;
extern char* yytext;
void yyerror(const char *s);
%}

%union {
    int number;
    char *string;
}

%token IF ELSE WHILE RETURN INT VOID
%token <string> ID
%token <number> NUM
%token PLUS MINUS TIMES DIVIDE
%token LT LTE GT GTE EQ NEQ
%token ASSIGN SEMI COMMA
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

%right ASSIGN
%left EQ NEQ
%left LT LTE GT GTE
%left PLUS MINUS
%left TIMES DIVIDE
%nonassoc THEN
%nonassoc ELSE

%%

program: declaration_list
       ;

declaration_list: declaration_list declaration
                | declaration
                ;

declaration: var_declaration
          | fun_declaration
          ;

var_declaration: type_specifier ID SEMI
               | type_specifier ID LBRACKET NUM RBRACKET SEMI
               ;

type_specifier: INT    { printf("PARSE: Found INT type\n"); }
              | VOID   { printf("PARSE: Found VOID type\n"); }
              ;

fun_declaration: type_specifier ID LPAREN params RPAREN compound_stmt
               ;

params: param_list
      | VOID          { printf("PARSE: Found VOID params\n"); }
      ;

param_list: param_list COMMA param
          | param
          ;

param: type_specifier ID
     | type_specifier ID LBRACKET RBRACKET
     ;

compound_stmt: LBRACE local_declarations statement_list RBRACE
             ;

local_declarations: local_declarations var_declaration
                 | /* empty */        { printf("PARSE: Empty local declarations\n"); }
                 ;

statement_list: statement_list statement
              | /* empty */          { printf("PARSE: Empty statement list\n"); }
              ;

statement: expression_stmt
         | compound_stmt
         | selection_stmt
         | iteration_stmt
         | return_stmt
         ;

expression_stmt: expression SEMI
               | SEMI
               ;

selection_stmt: IF LPAREN expression RPAREN statement %prec THEN
              | IF LPAREN expression RPAREN statement ELSE statement
              ;

iteration_stmt: WHILE LPAREN expression RPAREN statement
              ;

return_stmt: RETURN SEMI            { printf("PARSE: Return void\n"); }
           | RETURN expression SEMI { printf("PARSE: Return with expression\n"); }
           ;

expression: var ASSIGN expression
          | simple_expression
          ;

var: ID                            { printf("PARSE: Variable %s\n", $1); }
   | ID LBRACKET expression RBRACKET
   ;

simple_expression: additive_expression relop additive_expression
                | additive_expression
                ;

relop: LTE | LT | GT | GTE | EQ | NEQ
     ;

additive_expression: additive_expression addop term
                  | term
                  ;

addop: PLUS | MINUS
     ;

term: term mulop factor
    | factor
    ;

mulop: TIMES | DIVIDE
     ;

factor: LPAREN expression RPAREN
      | var
      | call
      | NUM                        { printf("PARSE: Number %d\n", $1); }
      ;

call: ID LPAREN args RPAREN
    ;

args: arg_list
    | /* empty */
    ;

arg_list: arg_list COMMA expression
        | expression
        ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser error near '%s': %s\n", yytext, s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    
    printf("Starting parsing...\n");
    int result = yyparse();
    printf("Parsing finished with result: %d\n", result);
    return result;
}