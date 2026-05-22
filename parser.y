%code requires {

typedef struct {

    int value;
    char place[50];

} Node;

}

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
void yyerror(const char *s);

extern char lexerOutput[];

typedef struct {

    char name[50];
    int value;

} Symbol;

Symbol table[100];

int symbolCount = 0;

char tac[200][100];
int tacIndex = 0;

char assembly[200][100];
int asmIndex = 0;

char parserOutput[5000] = "";

int tempCount = 0;
int labelCount = 0;

int getValue(char *name) {

    for(int i=0;i<symbolCount;i++) {

        if(strcmp(table[i].name,name)==0)
            return table[i].value;
    }

    return 0;
}

void setValue(char *name,int value) {

    for(int i=0;i<symbolCount;i++) {

        if(strcmp(table[i].name,name)==0) {

            table[i].value = value;
            return;
        }
    }

    strcpy(table[symbolCount].name,name);
    table[symbolCount].value = value;

    symbolCount++;
}

%}

%union {

    int num;
    char *str;
    Node node;
}

%token <num> NUMBER
%token <str> ID

%token IF WHILE PRINT

%left '+' '-'
%left '*' '/'

%type <node> expr

%%

program:
    statements
;

statements:
    statements statement
    |
;

statement:

      ID '=' expr {

            char temp[200];

            setValue($1,$3.value);

            sprintf(temp,
            "\n[Parser] Assigned %s = %d\n",
            $1,$3.value);

            strcat(parserOutput,temp);

            sprintf(tac[tacIndex++],
            "%s = %s",
            $1,$3.place);

            sprintf(assembly[asmIndex++],
            "MOV %s, %s",
            $1,$3.place);
      }

    | IF expr '>' expr {

            strcat(parserOutput,
            "\n[Parser] IF Condition\n");

            sprintf(tac[tacIndex++],
            "if %s > %s goto L%d",
            $2.place,$4.place,labelCount);

            sprintf(assembly[asmIndex++],
            "CMP %s, %s",
            $2.place,$4.place);

            sprintf(assembly[asmIndex++],
            "JG L%d",
            labelCount);

            labelCount++;
      }

    | WHILE expr '<' expr {

            strcat(parserOutput,
            "\n[Parser] WHILE Loop\n");

            sprintf(tac[tacIndex++],
            "L%d: while %s < %s",
            labelCount,
            $2.place,
            $4.place);

            sprintf(tac[tacIndex++],
            "goto L%d",
            labelCount);

            sprintf(assembly[asmIndex++],
            "L%d:",
            labelCount);

            sprintf(assembly[asmIndex++],
            "CMP %s, %s",
            $2.place,
            $4.place);

            sprintf(assembly[asmIndex++],
            "JL L%d",
            labelCount);

            labelCount++;
      }

    | PRINT ID {

            char temp[200];

            sprintf(temp,
            "\n[Parser] Print %s\n",$2);

            strcat(parserOutput,temp);

            sprintf(tac[tacIndex++],
            "print %s",$2);

            sprintf(assembly[asmIndex++],
            "OUT %s",$2);
      }

;

expr:

      expr '+' expr {

            char temp[200];

            $$.value =
            $1.value + $3.value;

            sprintf($$.place,
            "t%d",
            tempCount);

            sprintf(temp,
            "\n[TAC] %s = %s + %s\n",
            $$.place,
            $1.place,
            $3.place);

            strcat(parserOutput,temp);

            sprintf(tac[tacIndex++],
            "%s = %s + %s",
            $$.place,
            $1.place,
            $3.place);

            sprintf(assembly[asmIndex++],
            "ADD %s, %s",
            $1.place,
            $3.place);

            tempCount++;
      }

    | expr '-' expr {

            char temp[200];

            $$.value =
            $1.value - $3.value;

            sprintf($$.place,
            "t%d",
            tempCount);

            sprintf(temp,
            "\n[TAC] %s = %s - %s\n",
            $$.place,
            $1.place,
            $3.place);

            strcat(parserOutput,temp);

            sprintf(tac[tacIndex++],
            "%s = %s - %s",
            $$.place,
            $1.place,
            $3.place);

            sprintf(assembly[asmIndex++],
            "SUB %s, %s",
            $1.place,
            $3.place);

            tempCount++;
      }

    | NUMBER {

            $$.value = $1;

            sprintf($$.place,"%d",$1);
      }

    | ID {

            $$.value = getValue($1);

            strcpy($$.place,$1);
      }

;

%%

int main() {

    printf("========== MINI COMPILER ==========\n");
    printf("============================================\n\n");

    printf("----- Phase 1: Lexical Analysis -----\n\n");

    printf("[Lexer] Tokenizing Input...\n\n");

    printf("%-10s %-15s %-15s\n",
    "No","Type","Value");

    printf("------------------------------------------------\n");

    yyparse();

    printf("%s",lexerOutput);

    printf("\n----- Phase 2: Parsing & Semantic Analysis -----\n");

    printf("%s",parserOutput);

    printf("\n----- Phase 3: Symbol Table -----\n\n");

    printf("Name\t\tValue\n");
    printf("----------------------\n");

    for(int i=0;i<symbolCount;i++) {

        printf("%-15s %d\n",
        table[i].name,
        table[i].value);
    }

    printf("\n\n----- Phase 4: Intermediate Code -----\n\n");

    for(int i=0;i<tacIndex;i++) {

        printf("%s\n",tac[i]);
    }

    printf("\n\n----- Phase 5: Assembly Code -----\n\n");

    for(int i=0;i<asmIndex;i++) {

        printf("%s\n",assembly[i]);
    }

    printf("\n\n============================================\n");
    printf("        COMPILATION COMPLETED\n");
    printf("============================================\n");

    return 0;
}

void yyerror(const char *s) {

    printf("\nSyntax Error: %s\n",s);
}
