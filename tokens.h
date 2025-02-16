#ifndef TOKENS_H
#define TOKENS_H

#include "cminus.tab.h"  

extern FILE* yyin;
extern int yylex();
extern char* yytext;
extern int yylineno;


#endif /* TOKENS_H */