%{
#include <stdio.h>

typedef enum {
    IF, ELSE, THEN, END, PRINT, BEGINN,
    ID, NUM,
    ASSIGN, SEMI,
} TokenType;

int lineNo = 1;

// Prototipo da função printToken
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
"then"      { printToken(THEN, yytext); }     // Reconhece "then"
"print"     { printToken(PRINT, yytext); }    // Reconhece "print"
"end"       { printToken(END, yytext); }      // Reconhece "end"
"begin"     { printToken(BEGINN, yytext); }   // Reconhece "begin"
"="         { printToken(ASSIGN, yytext); }   // Operador de atribuição
";"         { printToken(SEMI, yytext); }     // Ponto e vírgula

{identifier} { printToken(ID, yytext); }      // Identificadores
{number}     { printToken(NUM, yytext); }     // Números inteiros
{comment}    { /* Ignorar comentários */ } // Ignorar comentários
{whitespace} { /* Ignorar espaços e tabs */ }
{newline}    { lineNo++; }                  // Incrementar o número da linha

.           { printf("Caractere invalido na Linha %d:  %s\n", lineNo, yytext); } // Printar quando tiver caractere inválido

%%

int yywrap() {
    return 1;
}

char *tok;
int line;
FILE* input;

char * getToken(){

    char str[100];

    str=yylex();

    return str;

}

void advance(){
    tok = getToken();
}

void ERRO(){
    printf("ERRO na Análise Sintática: %d %s", lineNo, tok);
}

void eat(char* t){
    if (strcmp(tok,t)==0)
        advance();
    else 
        ERRO();
}

void E() {
    if (strcmp(tok, "ID") == 0) {
        eat("ID");
        eat("ASSIGN");  // Usando "=" como o token "="
        eat("NUM"); // Consome o número
    }
    else
        ERRO();     // Caso o token não corresponda a nenhum dos casos
}

void S(){}

void L() {
    if (strcmp(tok, "SEMI") == 0) {  // Comparando com o token ";"
        eat(";");
        S();      // Chama a função recursiva S
        L();      // Chama a função recursiva L
    }
    else if (strcmp(tok, "END") == 0) {
        eat("END");
    }
    else
        ERRO();   // Caso o token não corresponda a nenhum dos casos
}

void S() {
    if (strcmp(tok, "BEGIN") == 0) {
        eat("BEGIN");
        S();      // Chama a função recursiva S
        L();      // Chama a função L
    }
    else if (strcmp(tok, "IF") == 0) {
        eat("IF");
        E();      // Chama a função E
        eat("THEN");
        S();      // Chama a função recursiva S
        eat("ELSE");
        S();      // Chama a função recursiva S novamente
    }
    else if (strcmp(tok, "PRINT") == 0) {
        eat("PRINT");
        eat("ID");  // Chama a função eat para consumir o identificador
    }
    else
        ERRO();   // Caso o token não corresponda a nenhum dos casos
}


int main(int argc, char **argv){
    
    FILE* input = fopen("program.txt", "r");
    if (input == NULL) {
        perror("Error opening input file");
        return 1;  // Exit the program with a non-zero status indicating an error
    }

    yyin = file;

    advance(input);
    S();
    printf("Sucesso");
    
    // Fechar o arquivo de saída
    fclose(output);
    return 0;
}

