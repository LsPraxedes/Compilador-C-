%{ 
#include <stdio.h>

typedef enum {
    IF, ELSE, WHILE, RETURN, INT, VOID,
    ID, NUM,
    PLUS, MINUS, TIMES, DIV,
    LT, LTE, GT, GTE, EQ, NEQ,
    ASSIGN,
    SEMI, COMMA,
    LPAREN, RPAREN, LBRACK, RBRACK,
    LBRACE, RBRACE
} TokenType;

int lineNo = 1;
void printToken(TokenType token, char* lexeme);
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
whitespace  [ \t]
newline     \n
comment     "/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+"/"

%%

"if"        { printToken(IF, yytext); }       // Reconhece a palavra-chave "if"
"else"      { printToken(ELSE, yytext); }     // Reconhece "else"
"while"     { printToken(WHILE, yytext); }    // Reconhece "while"
"return"    { printToken(RETURN, yytext); }   // Reconhece "return"
"int"       { printToken(INT, yytext); }      // Reconhece "int"
"void"      { printToken(VOID, yytext); }     // Reconhece "void"

"+"         { printToken(PLUS, yytext); }    // Operador +
"-"         { printToken(MINUS, yytext); }   // Operador -
"*"         { printToken(TIMES, yytext); }   // Operador *
"/"         { printToken(DIV, yytext); }    // Operador /

"<"         { printToken(LT, yytext); }     // Operador <
"<="        { printToken(LTE, yytext); }    // Operador <=
">"         { printToken(GT, yytext); }     // Operador >
">="        { printToken(GTE, yytext); }    // Operador >=
"=="        { printToken(EQ, yytext); }     // Operador ==
"!="        { printToken(NEQ, yytext); }    // Operador !=
"="         { printToken(ASSIGN, yytext); } // Operador de atribuição


";"         { printToken(SEMI, yytext); }   // Ponto e vírgula
","         { printToken(COMMA, yytext); }  // Vírgula
"("         { printToken(LPAREN, yytext); } // Parêntese esquerdo
")"         { printToken(RPAREN, yytext); } // Parêntese direito
"["         { printToken(LBRACK, yytext); } // Colchete esquerdo
"]"         { printToken(RBRACK, yytext); } // Colchete direito
"{"         { printToken(LBRACE, yytext); } // Chave esquerda
"}"         { printToken(RBRACE, yytext); } // Chave direita

{identifier} { printToken(ID, yytext); }   // Identificadores (variáveis, funções, etc.)
{number}     { printToken(NUM, yytext); }  // Números inteiros
{comment}    { /* Ignorar comentários */ } // Ignorar comentários
{whitespace} { /* Ignorar espaços e tabs */ }
{newline}    { lineNo++; }                 // Incrementar o número da linha


.           { printf("Caractere invalido na Linha %d:  %s\n", lineNo, yytext); } //printar quando tiver caractere inválido

%%

void printToken(TokenType token, char* lexeme) {
    char* tokenNames[] = {
        "IF", "ELSE", "WHILE", "RETURN", "INT", "VOID",
        "ID", "NUM",
        "PLUS", "MINUS", "TIMES", "DIV",
        "LT", "LTE", "GT", "GTE", "EQ", "NEQ",
        "ASSIGN",
        "SEMI", "COMMA",
        "LPAREN", "RPAREN", "LBRACK", "RBRACK",
        "LBRACE", "RBRACE"
    };
    printf("Line %d: Token=%-10s Lexeme=%s\n", lineNo, tokenNames[token], lexeme);
}

int yywrap() {
    return 1;
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
    yylex();
    return 0;
} //Andre Eiki Hiratsuka e Lucas Praxedes Fischer de Mattos