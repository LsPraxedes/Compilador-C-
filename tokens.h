#ifndef TOKENS_H
#define TOKENS_H

#include "cminus.tab.h"  // Include Bison-generated token definitions

// Add any additional token-related declarations here that aren't in cminus.tab.h
extern FILE* yyin;
extern int yylex();
extern char* yytext;
extern int yylineno;


#endif /* TOKENS_H */