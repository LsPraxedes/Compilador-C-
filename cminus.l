%{
#include <stdio.h>
#include <string.h>
#include "cminus.tab.h"

void yyerror(const char *s);
int debug = 1; 
int line_num = 1;  
%}



%x COMMENT
%x LINE_COMMENT

%%
"/*"            { BEGIN(COMMENT); }
<COMMENT>"*/"   { BEGIN(INITIAL);  }
<COMMENT>\n     { line_num++; }
<COMMENT>.      { }

"//"            { BEGIN(LINE_COMMENT); }
<LINE_COMMENT>\n { line_num++; BEGIN(INITIAL);  }
<LINE_COMMENT>. { }

"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"return"    { return RETURN; }
"int"       { return INT; }
"void"      { return VOID; }

[a-zA-Z]+   { 
    yylval.string = strdup(yytext);
    return ID;
}

[a-zA-Z]+[0-9]+   { 
    printf("ERRO LEXICO: %s LINHA: %d\n", yytext, line_num);
    yyerror("Invalid identifier");
    exit(1);
}

[0-9]+[a-zA-Z]+  { 
    printf("ERRO LEXICO: %s LINHA: %d\n", yytext, line_num);
    yyerror("Invalid identifier");
    exit(1);
}

[0-9]+      { 
    yylval.number = atoi(yytext);
    return NUM;
}

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
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
"["         { return LBRACKET; }
"]"         { return RBRACKET; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }

\n          { line_num++;}
[ \t]       { }
.           { printf("ERRO LEXICO: %s, LINHA: %d\n", yytext, line_num); yyerror("Invalid character"); 
exit(1);}

%%

int yywrap() {
    return 1;
}