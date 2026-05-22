%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

if              { return IF; }
while           { return WHILE; }
print           { return PRINT; }

[0-9]+          {
                    yylval.num = atoi(yytext);
                    return NUMBER;
                }

[a-zA-Z_][a-zA-Z0-9_]* {
                    yylval.id = strdup(yytext);
                    return ID;
                }

">"             { return '>'; }
"<"             { return '<'; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"="             { return '='; }

[\n]+           ;
[ \t\r]+        ;

.               ;

%%

int yywrap()
{
    return 1;
}

