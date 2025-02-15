%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"

extern int yylex();
extern int line_num;
extern FILE* yyin;
extern char* yytext;
void yyerror(const char *s);

/* Tree node structure */
typedef struct TreeNode {
    char *node_type;
    char *value;
    int num_children;
    struct TreeNode *children[10];  // Maximum 10 children per node
} TreeNode;

/* Function to create a new tree node */
TreeNode* new_node(char *node_type, char *value) {
    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));
    node->node_type = strdup(node_type);
    node->value = value ? strdup(value) : NULL;
    node->num_children = 0;
    return node;
}

/* Function to add child to a node */
void add_child(TreeNode *parent, TreeNode *child) {
    if (child && parent->num_children < 10) {
        parent->children[parent->num_children++] = child;
    }
}

/* Function to print the tree */
void print_tree(TreeNode *node, int depth) {
    if (node == NULL) return;
    
    // Print indentation
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    // Print node information
    printf("%s", node->node_type);
    if (node->value) {
        printf(" (%s)", node->value);
    }
    printf("\n");
    
    // Print children
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], depth + 1);
    }
}

TreeNode *root = NULL;  // Root of the syntax tree
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

/* Your precedence rules remain the same */
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
            $$ = new_node("Program", NULL);
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
            $$ = new_node("DeclarationList", NULL);
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
            $$ = new_node("VarDeclaration", $2);
            add_child($$, $1);
        }
    | type_specifier ID LBRACKET NUM RBRACKET SEMI
        {
            char num_str[32];
            sprintf(num_str, "%d", $4);
            $$ = new_node("ArrayDeclaration", $2);
            add_child($$, $1);
            add_child($$, new_node("Size", num_str));
        }
    ;

type_specifier
    : INT
        {
            $$ = new_node("Type", "int");
        }
    | VOID
        {
            $$ = new_node("Type", "void");
        }
    ;

fun_declaration
    : type_specifier ID LPAREN params RPAREN compound_stmt
        {
            $$ = new_node("FunctionDeclaration", $2);
            add_child($$, $1);  // return type
            add_child($$, $4);  // parameters
            add_child($$, $6);  // function body
        }
    ;

params
    : param_list
        {
            $$ = new_node("Parameters", NULL);
            add_child($$, $1);
        }
    | VOID
        {
            $$ = new_node("Parameters", "void");
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
            $$ = new_node("ParameterList", NULL);
            add_child($$, $1);
        }
    ;

param
    : type_specifier ID
        {
            $$ = new_node("Parameter", $2);
            add_child($$, $1);
        }
    | type_specifier ID LBRACKET RBRACKET
        {
            $$ = new_node("ArrayParameter", $2);
            add_child($$, $1);
        }
    ;

compound_stmt
    : LBRACE local_declarations statement_list RBRACE
        {
            $$ = new_node("CompoundStatement", NULL);
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
            $$ = new_node("LocalDeclarations", NULL);
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
            $$ = new_node("StatementList", NULL);
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
            $$ = new_node("ExpressionStatement", NULL);
            add_child($$, $1);
        }
    | SEMI
        {
            $$ = new_node("EmptyStatement", NULL);
        }
    ;

selection_stmt
    : IF LPAREN expression RPAREN statement %prec THEN
        {
            $$ = new_node("IfStatement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // then branch
        }
    | IF LPAREN expression RPAREN statement ELSE statement
        {
            $$ = new_node("IfElseStatement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // then branch
            add_child($$, $7);  // else branch
        }
    ;

iteration_stmt
    : WHILE LPAREN expression RPAREN statement
        {
            $$ = new_node("WhileStatement", NULL);
            add_child($$, $3);  // condition
            add_child($$, $5);  // body
        }
    ;

return_stmt
    : RETURN SEMI
        {
            $$ = new_node("ReturnStatement", "void");
        }
    | RETURN expression SEMI
        {
            $$ = new_node("ReturnStatement", NULL);
            add_child($$, $2);
        }
    ;

expression
    : var ASSIGN expression
        {
            $$ = new_node("AssignExpression", NULL);
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
            $$ = new_node("Variable", $1);
        }
    | ID LBRACKET expression RBRACKET
        {
            $$ = new_node("ArrayAccess", $1);
            add_child($$, $3);  // index
        }
    ;

simple_expression
    : additive_expression relop additive_expression
        {
            $$ = new_node("RelationalExpression", NULL);
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
    : LTE   { $$ = new_node("Operator", "<="); }
    | LT    { $$ = new_node("Operator", "<"); }
    | GT    { $$ = new_node("Operator", ">"); }
    | GTE   { $$ = new_node("Operator", ">="); }
    | EQ    { $$ = new_node("Operator", "=="); }
    | NEQ   { $$ = new_node("Operator", "!="); }
    ;

additive_expression
    : additive_expression addop term
        {
            $$ = new_node("AdditiveExpression", NULL);
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
    : PLUS    { $$ = new_node("Operator", "+"); }
    | MINUS   { $$ = new_node("Operator", "-"); }
    ;

term
    : term mulop factor
        {
            $$ = new_node("MultiplicativeExpression", NULL);
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
    : TIMES   { $$ = new_node("Operator", "*"); }
    | DIVIDE  { $$ = new_node("Operator", "/"); }
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
            $$ = new_node("Number", num_str);
        }
    ;

call
    : ID LPAREN args RPAREN
        {
            $$ = new_node("FunctionCall", $1);
            add_child($$, $3);
        }
    ;

args
    : arg_list
        {
            $$ = new_node("Arguments", NULL);
            add_child($$, $1);
        }
    | /* empty */
        {
            $$ = new_node("Arguments", "void");
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
            $$ = new_node("ArgumentList", NULL);
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
    
    printf("Starting parsing...\n");
    int result = yyparse();
    
    if (result == 0 && root != NULL) {
        printf("\nSyntax Tree:\n");
        print_tree(root, 0);
    }
    
    printf("Parsing finished with result: %d\n", result);
    return result;
}