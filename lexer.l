%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int token_count = 0;

char lexerOutput[5000] = "";

%}

%%

"if" {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "KEYWORD",
    yytext);

    strcat(lexerOutput,temp);

    return IF;
}

"while" {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "KEYWORD",
    yytext);

    strcat(lexerOutput,temp);

    return WHILE;
}

"print" {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "KEYWORD",
    yytext);

    strcat(lexerOutput,temp);

    return PRINT;
}

[0-9]+ {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "INT_NUM",
    yytext);

    strcat(lexerOutput,temp);

    yylval.num = atoi(yytext);

    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "ID",
    yytext);

    strcat(lexerOutput,temp);

    yylval.str = strdup(yytext);

    return ID;
}

"="|"+"|"-"|"*"|"/"|">"|"<" {

    char temp[200];

    sprintf(temp,
    "%-10d %-15s %-15s\n",
    ++token_count,
    "OPERATOR",
    yytext);

    strcat(lexerOutput,temp);

    return yytext[0];
}

[ \t\n] ;

. ;

%%

int yywrap() {

    return 1;
}
