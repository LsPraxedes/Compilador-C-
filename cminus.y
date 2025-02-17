%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "tree.h"  

extern int yylex();
extern int line_num;
extern FILE* yyin;
extern char* yytext;
void yyerror(const char *s);

// Declaração da função do analisador semântico
void execute_semantic_analysis(TreeNode *root);


%}

%union {
    int number;
    char *string;
    struct TreeNode *node;
}

%token IF ELSE WHILE RETURN INT VOID
%token <string> ID
%token <number> NUM
%token PLUS MINUS TIMES DIVIDE
%token LT LTE GT GTE EQ NEQ
%token ASSIGN SEMI COMMA
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

%type <node> program declaration_list declaration var_declaration
%type <node> type_specifier fun_declaration params param_list param
%type <node> compound_stmt local_declarations statement_list statement
%type <node> expression_stmt selection_stmt iteration_stmt return_stmt
%type <node> expression var simple_expression relop additive_expression
%type <node> addop term mulop factor call args arg_list


%right ASSIGN
%left EQ NEQ
%left LT LTE GT GTE
%left PLUS MINUS
%left TIMES DIVIDE
%nonassoc THEN
%nonassoc ELSE

%%

program
    : declaration_list
        { 
            $$ = new_node("Programa", NULL);
            add_child($$, $1);
            root = $$;
        }
    ;

declaration_list
    : declaration_list declaration
        {
            $$ = $1;
            add_child($$, $2);
        }
    | declaration
        {
            $$ = new_node("Declaracao-lista", NULL);
            add_child($$, $1);
        }
    ;

declaration
    : var_declaration
        {
            $$ = $1;
        }
    | fun_declaration
        {
            $$ = $1;
        }
    ;

var_declaration
    : type_specifier ID SEMI
        {
            $$ = new_node("Var-declaracao", $2);
            add_child($$, $1);
        }
    | type_specifier ID LBRACKET NUM RBRACKET SEMI
        {
            char num_str[32];
            sprintf(num_str, "%d", $4);
            $$ = new_node("Fun-declaracao", $2);
            add_child($$, $1);
            add_child($$, new_node("Size", num_str));
        }
    ;

type_specifier
    : INT
        {
            $$ = new_node("Tipo", "int");
        }
    | VOID
        {
            $$ = new_node("Tipo", "void");
        }
    ;

fun_declaration
    : type_specifier ID LPAREN params RPAREN compound_stmt
        {
            $$ = new_node("Fun-declaracao", $2);
            add_child($$, $1);  // return type
            add_child($$, $4);  // parameters
            add_child($$, $6);  // function body
        }
    ;

params
    : param_list
        {
            $$ = new_node("params", NULL);
            add_child($$, $1);
        }
    | VOID
        {
            $$ = new_node("params", "void");
        }
    ;

param_list
    : param_list COMMA param
        {
            $$ = $1;
            add_child($$, $3);
        }
    | param
        {
            $$ = new_node("Param-lista", NULL);
            add_child($$, $1);
        }
    ;

param
    : type_specifier ID
        {
            $$ = new_node("params", $2);
            add_child($$, $1);
        }
    | type_specifier ID LBRACKET RBRACKET
        {
            $$ = new_node("params-lista", $2);
            add_child($$, $1);
        }
    ;

compound_stmt
    : LBRACE local_declarations statement_list RBRACE
        {
            $$ = new_node("Composto-declaracao", NULL);
            add_child($$, $2);  // local declarations
            add_child($$, $3);  // statement list
        }
    ;

local_declarations
    : local_declarations var_declaration
        {
            $$ = $1;
            add_child($$, $2);
        }
    | /* empty */
        {
            $$ = new_node("local-declaracao", NULL);
        }
    ;

statement_list
    : statement_list statement
        {
            $$ = $1;
            add_child($$, $2);
        }
    | /* empty */
        {
            $$ = new_node("Statement-lista", NULL);
        }
    ;

statement
    : expression_stmt
        {
            $$ = $1;
        }
    | compound_stmt
        {
            $$ = $1;
        }
    | selection_stmt
        {
            $$ = $1;
        }
    | iteration_stmt
        {
            $$ = $1;
        }
    | return_stmt
        {
            $$ = $1;
        }
    ;

expression_stmt
    : expression SEMI
        {
            $$ = new_node("Expressao-declaracao", NULL);
            add_child($$, $1);
        }
    | SEMI
        {
            $$ = new_node("statement-vazio", NULL);
        }
    ;

selection_stmt
    : IF LPAREN expression RPAREN statement %prec THEN
        {
            $$ = new_node("If-Statement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // then branch
        }
    | IF LPAREN expression RPAREN statement ELSE statement
        {
            $$ = new_node("If-Else-Statement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // then branch
            add_child($$, $7);  // else branch
        }
    ;

iteration_stmt
    : WHILE LPAREN expression RPAREN statement
        {
            $$ = new_node("While-Statement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // body
        }
    ;

return_stmt
    : RETURN SEMI
        {
            $$ = new_node("Return-Statement", "void");
        }
    | RETURN expression SEMI
        {
            $$ = new_node("Return-Statement", NULL);
            add_child($$, $2);
        }
    ;

expression
    : var ASSIGN expression
        {
            $$ = new_node("Assign-Expression", NULL);
            add_child($$, $1);  // variable
            add_child($$, $3);  // value
        }
    | simple_expression
        {
            $$ = $1;
        }
    ;

var
    : ID
        {
            $$ = new_node("Variavel", $1);
        }
    | ID LBRACKET expression RBRACKET
        {
            $$ = new_node("Variavel-Array", $1);
            add_child($$, $3);  // index
        }
    ;

simple_expression
    : additive_expression relop additive_expression
        {
            $$ = new_node("Expressao", NULL);
            add_child($$, $1);  // left operand
            add_child($$, $2);  // operator
            add_child($$, $3);  // right operand
        }
    | additive_expression
        {
            $$ = $1;
        }
    ;

relop
    : LTE   { $$ = new_node("operador", "<="); }
    | LT    { $$ = new_node("operador", "<"); }
    | GT    { $$ = new_node("operador", ">"); }
    | GTE   { $$ = new_node("operador", ">="); }
    | EQ    { $$ = new_node("operador", "=="); }
    | NEQ   { $$ = new_node("operador", "!="); }
    ;

additive_expression
    : additive_expression addop term
        {
            $$ = new_node("soma-Expressao", NULL);
            add_child($$, $1);  // left operand
            add_child($$, $2);  // operator
            add_child($$, $3);  // right operand
        }
    | term
        {
            $$ = $1;
        }
    ;

addop
    : PLUS    { $$ = new_node("operador", "+"); }
    | MINUS   { $$ = new_node("operador", "-"); }
    ;

term
    : term mulop factor
        {
            $$ = new_node("mult-Expressao", NULL);
            add_child($$, $1);  // left operand
            add_child($$, $2);  // operator
            add_child($$, $3);  // right operand
        }
    | factor
        {
            $$ = $1;
        }
    ;

mulop
    : TIMES   { $$ = new_node("operador", "*"); }
    | DIVIDE  { $$ = new_node("operador", "/"); }
    ;

factor
    : LPAREN expression RPAREN
        {
            $$ = $2;
        }
    | var
        {
            $$ = $1;
        }
    | call
        {
            $$ = $1;
        }
    | NUM
        {
            char num_str[32];
            sprintf(num_str, "%d", $1);
            $$ = new_node("Num", num_str);
        }
    ;

call
    : ID LPAREN args RPAREN
        {
            $$ = new_node("Function-Call", $1);
            add_child($$, $3);
        }
    ;

args
    : arg_list
        {
            $$ = new_node("Argumentos", NULL);
            add_child($$, $1);
        }
    | /* empty */
        {
            $$ = new_node("Argumentos", "void");
        }
    ;

arg_list
    : arg_list COMMA expression
        {
            $$ = $1;
            add_child($$, $3);
        }
    | expression
        {
            $$ = new_node("Argument-List", NULL);
            add_child($$, $1);
        }
    ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "ERRO SINTATICO: '%s' LINHA: %d\n", yytext, line_num);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    
    int result = yyparse();
    
    if (result == 0 && root != NULL) {
        // Chama o analisador semântico após o parsing bem-sucedido
        execute_semantic_analysis(root);
    }
    
    printf("\nParser retornou: %d\n", result);
    return result;
}