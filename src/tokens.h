#ifndef TOKENS_H
#define TOKENS_H

extern int lineNo;
extern char* yytext;
extern FILE* yyin;

int yylex(void);
void yyerror(const char* s);

#endif