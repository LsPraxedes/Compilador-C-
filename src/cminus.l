%{
#include "tokens.h"
#include "cminus.tab.h"
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
whitespace  [ \t]
newline     \n|\r|\r\n
comment     "/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+"/"

%%

"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"return"    { return RETURN; }
"int"       { return INT; }
"void"      { return VOID; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIV; }

"<"         { return LT; }
"<="        { return LTE; }
">"         { return GT; }
">="        { return GTE; }
"=="        { return EQ; }
"!="        { return NEQ; }
"="         { return ASSIGN; }

";"         { return SEMI; }
","         { return COMMA; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"["         { return LBRACK; }
"]"         { return RBRACK; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }

{identifier} { return ID; }
{number}     { return NUM; }
{comment}    { /* ignore */ }
{whitespace} { /* ignore */ }
{newline}    { lineNo++; }

.           { printf("Invalid character at line %d: %s\n", lineNo, yytext); }

%%

int yywrap() {
    return 1;
}