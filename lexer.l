%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_line = 1;

#define MAX_LOG 2000

typedef struct {
    char category[32];
    char value[64];
    int line;
} TokenInfo;

TokenInfo tokenLog[MAX_LOG];
int tokenCount = 0;

void saveToken(const char *cat, const char *val) {
    if(tokenCount >= MAX_LOG) return;

    strcpy(tokenLog[tokenCount].category, cat);
    strcpy(tokenLog[tokenCount].value, val);
    tokenLog[tokenCount].line = current_line;
    tokenCount++;
}

void displayTokens() {
    printf("+------------------------------------------------------ +\n");
    printf("| PHASE 1 : LEXICAL ANALYSIS                            |\n");
    printf("+------+----------------------+------------------------+\n");
    printf("| Line | Token Type           | Lexeme                |\n");
    printf("+------+----------------------+------------------------+\n");

    for(int i=0;i<tokenCount;i++) {
        printf("| %-4d | %-20s | %-22s |\n",
               tokenLog[i].line,
               tokenLog[i].category,
               tokenLog[i].value);
    }

    printf("+------+----------------------+------------------------+\n");
    printf("Total Tokens : %d\n\n", tokenCount);
}
%}

%%

[ \t\r]+              ;
\n                      { current_line++; }
"//"[^\n]*            ;

"int"                 { saveToken("KEYWORD", yytext); return INT; }
"print"               { saveToken("KEYWORD", yytext); return PRINT; }
"if"                  { saveToken("KEYWORD", yytext); return IF; }
"else"                { saveToken("KEYWORD", yytext); return ELSE; }
"while"               { saveToken("KEYWORD", yytext); return WHILE; }
"return"              { saveToken("KEYWORD", yytext); return RETURN; }

[a-zA-Z_][a-zA-Z0-9_]* {
    saveToken("IDENTIFIER", yytext);
    yylval.text = strdup(yytext);
    return IDENTIFIER;
}

[0-9]+ {
    saveToken("NUMBER", yytext);
    yylval.number = atoi(yytext);
    return NUMBER;
}

\"[^\"]*\" {
    saveToken("STRING", yytext);
    yylval.text = strdup(yytext);
    return STRING;
}

"=="                  { saveToken("EQUAL", yytext); return EQ; }
"!="                  { saveToken("NOT_EQUAL", yytext); return NEQ; }
"<="                  { saveToken("LESS_EQUAL", yytext); return LEQ; }
">="                  { saveToken("GREATER_EQUAL", yytext); return GEQ; }
"="                   { saveToken("ASSIGN", yytext); return ASSIGN; }
"+"                   { saveToken("PLUS", yytext); return PLUS; }
"-"                   { saveToken("MINUS", yytext); return MINUS; }
"*"                   { saveToken("MULTIPLY", yytext); return MUL; }
"/"                   { saveToken("DIVIDE", yytext); return DIV; }
"<"                   { saveToken("LESS", yytext); return LT; }
">"                   { saveToken("GREATER", yytext); return GT; }
"("                   { saveToken("LPAREN", yytext); return LP; }
")"                   { saveToken("RPAREN", yytext); return RP; }
"{"                   { saveToken("LBRACE", yytext); return LB; }
"}"                   { saveToken("RBRACE", yytext); return RB; }
";"                   { saveToken("SEMICOLON", yytext); return SC; }
","                   { saveToken("COMMA", yytext); return CM; }

. {
    printf("[LEXICAL ERROR] Invalid Character '%s' at line %d\n", yytext, current_line);
}

%%

int yywrap() {
    return 1;
}
