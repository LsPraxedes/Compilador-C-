%{
#include <stdio.h>
#include <string.h>
#include "cminus.tab.h"

void yyerror(const char *s);
int debug = 1;  /* Set to 1 to enable debug printing */
%}

%x COMMENT
%x LINE_COMMENT

%%
"/*"            { BEGIN(COMMENT); if(debug) printf("LEX: Start multiline comment\n"); }
<COMMENT>"*/"   { BEGIN(INITIAL); if(debug) printf("LEX: End multiline comment\n"); }
<COMMENT>\n     { /* Ignore newlines in comments */ }
<COMMENT>.      { /* Ignore everything else in comments */ }

"//"            { BEGIN(LINE_COMMENT); if(debug) printf("LEX: Start single-line comment\n"); }
<LINE_COMMENT>\n { BEGIN(INITIAL); if(debug) printf("LEX: End single-line comment\n"); }
<LINE_COMMENT>. { /* Ignore everything else in line comment */ }

"if"        { if(debug) printf("LEX: if\n"); return IF; }
"else"      { if(debug) printf("LEX: else\n"); return ELSE; }
"while"     { if(debug) printf("LEX: while\n"); return WHILE; }
"return"    { if(debug) printf("LEX: return\n"); return RETURN; }
"int"       { if(debug) printf("LEX: int\n"); return INT; }
"void"      { if(debug) printf("LEX: void\n"); return VOID; }

[a-zA-Z]+   { 
    if(debug) printf("LEX: ID (%s)\n", yytext);
    yylval.string = strdup(yytext);
    return ID;
}

[a-zA-Z][0-9]+   { 
    printf("Invalid identifier: %s (identifiers cannot contain digits)\n", yytext);
    yyerror("Invalid identifier");
}

[0-9]+      { 
    if(debug) printf("LEX: NUM (%s)\n", yytext);
    yylval.number = atoi(yytext);
    return NUM;
}

"+"         { if(debug) printf("LEX: +\n"); return PLUS; }
"-"         { if(debug) printf("LEX: -\n"); return MINUS; }
"*"         { if(debug) printf("LEX: *\n"); return TIMES; }
"/"         { if(debug) printf("LEX: /\n"); return DIVIDE; }
"<"         { if(debug) printf("LEX: <\n"); return LT; }
"<="        { if(debug) printf("LEX: <=\n"); return LTE; }
">"         { if(debug) printf("LEX: >\n"); return GT; }
">="        { if(debug) printf("LEX: >=\n"); return GTE; }
"=="        { if(debug) printf("LEX: ==\n"); return EQ; }
"!="        { if(debug) printf("LEX: !=\n"); return NEQ; }
"="         { if(debug) printf("LEX: =\n"); return ASSIGN; }
";"         { if(debug) printf("LEX: ;\n"); return SEMI; }
","         { if(debug) printf("LEX: ,\n"); return COMMA; }
"("         { if(debug) printf("LEX: (\n"); return LPAREN; }
")"         { if(debug) printf("LEX: )\n"); return RPAREN; }
"["         { if(debug) printf("LEX: [\n"); return LBRACKET; }
"]"         { if(debug) printf("LEX: ]\n"); return RBRACKET; }
"{"         { if(debug) printf("LEX: {\n"); return LBRACE; }
"}"         { if(debug) printf("LEX: }\n"); return RBRACE; }

[ \t\n]     { /* Skip whitespace */ }
.           { printf("Invalid character: %s\n", yytext); yyerror("Invalid character"); }

%%

int yywrap() {
    return 1;
}