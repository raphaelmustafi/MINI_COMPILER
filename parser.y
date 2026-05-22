%code requires {

typedef struct
{
    int value;
    char name[20];
} Node;

}

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

typedef struct
{
    char name[20];
    int value;
} Symbol;

Symbol table[100];

int symIndex = 0;

char tac[200][100];
int tacIndex = 0;

char assembly[200][100];
int asmIndex = 0;

int tempCount = 0;
int labelCount = 0;

char* newTemp()
{
    char *temp = malloc(10);

    sprintf(temp, "t%d", tempCount++);

    return temp;
}

char* newLabel()
{
    char *label = malloc(10);

    sprintf(label, "L%d", labelCount++);

    return label;
}

void addSymbol(char *name, int value)
{
    strcpy(table[symIndex].name, name);
    table[symIndex].value = value;

    symIndex++;
}

int getValue(char *name)
{
    for(int i=0; i<symIndex; i++)
    {
        if(strcmp(table[i].name, name)==0)
            return table[i].value;
    }

    return 0;
}

%}

%union{
    int num;
    char* id;
    Node node;
}

%token <num> NUMBER
%token <id> ID
%token IF WHILE PRINT

%left '+' '-'
%left '*' '/'

%type <node> expr

%%

program:
      program stmt
    | stmt
    ;

stmt:

      ID '=' expr
      {
          printf("[Parser] Assigned %s = %d\n",
                 $1, $3.value);

          addSymbol($1, $3.value);

          sprintf(tac[tacIndex++],
                  "%s = %s",
                  $1, $3.name);

          sprintf(assembly[asmIndex++],
                  "MOV %s, %s",
                  $1, $3.name);
      }

    | PRINT ID
      {
          printf("[Parser] Print %s\n", $2);

          sprintf(tac[tacIndex++],
                  "print %s",
                  $2);

          sprintf(assembly[asmIndex++],
                  "OUT %s",
                  $2);
      }

    | IF expr '>' expr
      {
          char *label = newLabel();

          printf("[Parser] IF Condition\n");

          sprintf(tac[tacIndex++],
                  "if %s > %s goto %s",
                  $2.name,
                  $4.name,
                  label);

          sprintf(assembly[asmIndex++],
                  "CMP %s, %s",
                  $2.name,
                  $4.name);

          sprintf(assembly[asmIndex++],
                  "JG %s",
                  label);

          sprintf(assembly[asmIndex++],
                  "%s:",
                  label);
      }

    | WHILE expr '<' expr
      {
          char *start = newLabel();
          char *end = newLabel();

          printf("[Parser] WHILE Loop\n");

          sprintf(tac[tacIndex++],
                  "%s: while %s < %s",
                  start,
                  $2.name,
                  $4.name);

          sprintf(tac[tacIndex++],
                  "goto %s",
                  start);

          sprintf(assembly[asmIndex++],
                  "%s:",
                  start);

          sprintf(assembly[asmIndex++],
                  "CMP %s, %s",
                  $2.name,
                  $4.name);

          sprintf(assembly[asmIndex++],
                  "JL %s",
                  start);

          sprintf(assembly[asmIndex++],
                  "%s:",
                  end);
      }
    ;

expr:

      NUMBER
      {
          $$.value = $1;

          sprintf($$.name, "%d", $1);
      }

    | ID
      {
          $$.value = getValue($1);

          strcpy($$.name, $1);
      }

    | expr '+' expr
      {
          char *temp = newTemp();

          $$.value = $1.value + $3.value;

          strcpy($$.name, temp);

          printf("[TAC] %s = %s + %s\n",
                 temp,
                 $1.name,
                 $3.name);

          sprintf(tac[tacIndex++],
                  "%s = %s + %s",
                  temp,
                  $1.name,
                  $3.name);

          sprintf(assembly[asmIndex++],
                  "ADD %s, %s",
                  $1.name,
                  $3.name);
      }

    | expr '-' expr
      {
          char *temp = newTemp();

          $$.value = $1.value - $3.value;

          strcpy($$.name, temp);

          printf("[TAC] %s = %s - %s\n",
                 temp,
                 $1.name,
                 $3.name);

          sprintf(tac[tacIndex++],
                  "%s = %s - %s",
                  temp,
                  $1.name,
                  $3.name);

          sprintf(assembly[asmIndex++],
                  "SUB %s, %s",
                  $1.name,
                  $3.name);
      }

    | expr '*' expr
      {
          char *temp = newTemp();

          $$.value = $1.value * $3.value;

          strcpy($$.name, temp);

          printf("[TAC] %s = %s * %s\n",
                 temp,
                 $1.name,
                 $3.name);

          sprintf(tac[tacIndex++],
                  "%s = %s * %s",
                  temp,
                  $1.name,
                  $3.name);

          sprintf(assembly[asmIndex++],
                  "MUL %s, %s",
                  $1.name,
                  $3.name);
      }

    | expr '/' expr
      {
          char *temp = newTemp();

          $$.value = $1.value / $3.value;

          strcpy($$.name, temp);

          printf("[TAC] %s = %s / %s\n",
                 temp,
                 $1.name,
                 $3.name);

          sprintf(tac[tacIndex++],
                  "%s = %s / %s",
                  temp,
                  $1.name,
                  $3.name);

          sprintf(assembly[asmIndex++],
                  "DIV %s, %s",
                  $1.name,
                  $3.name);
      }
    ;

%%

void yyerror(const char *s)
{
    printf("Syntax Error: %s\n", s);
}

int main()
{
    printf("========== MINI COMPILER ==========\n");
    printf("============================================\n\n");

    printf("----- Phase 1: Lexical Analysis -----\n");
    printf("[Lexer] Tokenizing Input...\n\n");

    printf("----- Phase 2: Parsing & Semantic Analysis -----\n");

    yyparse();

    printf("\n----- Phase 3: Symbol Table -----\n\n");

    printf("Name\t\tValue\n");
    printf("----------------------\n");

    for(int i=0; i<symIndex; i++)
    {
        printf("%s\t\t%d\n",
               table[i].name,
               table[i].value);
    }

    printf("\n----- Phase 4: Intermediate Code -----\n\n");

    for(int i=0; i<tacIndex; i++)
    {
        printf("%s\n", tac[i]);
    }

    printf("\n----- Phase 5: Assembly Code -----\n\n");

    for(int i=0; i<asmIndex; i++)
    {
        printf("%s\n", assembly[i]);
    }

    return 0;
}
