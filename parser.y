
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

extern int current_line;
extern void displayTokens();

#define TABLE_SIZE 500
#define TAC_SIZE 1000

int semanticErrors = 0;

char syntaxRules[500][100];
int syntaxCount = 0;

void saveRule(const char *rule) {
    strcpy(syntaxRules[syntaxCount++], rule);
}

typedef struct {
    char name[32];
    int value;
    int scope;
} Symbol;

Symbol symbolTable[TABLE_SIZE];
int symbolCount = 0;

void addSymbol(char *name, int value) {
    for(int i=symbolCount-1;i>=0;i--) {
        if(strcmp(symbolTable[i].name, name)==0) {
            symbolTable[i].value = value;
            return;
        }
    }

    strcpy(symbolTable[symbolCount].name, name);
    symbolTable[symbolCount].value = value;
    symbolTable[symbolCount].scope = 0;
    symbolCount++;
}

int getValue(char *name) {
    for(int i=symbolCount-1;i>=0;i--) {
        if(strcmp(symbolTable[i].name, name)==0)
            return symbolTable[i].value;
    }

    printf("[SEMANTIC ERROR] Undefined Variable '%s' at line %d\n", name, current_line);
    semanticErrors++;
    return 0;
}

typedef struct {
    char op[10];
    char arg1[40];
    char arg2[40];
    char result[40];
    int removed;
} TAC;

TAC tac[TAC_SIZE];
int tacIndex = 0;
int tempCount = 0;

void generateCode(char *op, char *a1, char *a2, char *res) {
    strcpy(tac[tacIndex].op, op);
    strcpy(tac[tacIndex].arg1, a1);
    strcpy(tac[tacIndex].arg2, a2);
    strcpy(tac[tacIndex].result, res);
    tac[tacIndex].removed = 0;
    tacIndex++;
}

char* newTemp() {
    char *buffer = (char*)malloc(20);
    sprintf(buffer, "temp%d", tempCount++);
    return buffer;
}

int isNumber(char *s) {
    for(int i=0;s[i];i++) {
        if(s[i] < '0' || s[i] > '9')
            return 0;
    }
    return 1;
}

void showTAC() {
    printf("+----------------------------------------------------+\n");
    printf("| PHASE 4 : INTERMEDIATE CODE GENERATION             |\n");
    printf("+----------------------------------------------------+\n");

    for(int i=0;i<tacIndex;i++) {
        if(tac[i].removed) continue;

        if(strcmp(tac[i].op, "PRINT") == 0)
            printf("print %s\n", tac[i].arg1);

        else if(strcmp(tac[i].op, "=") == 0)
            printf("%s = %s\n", tac[i].result, tac[i].arg1);

        else
            printf("%s = %s %s %s\n",
                tac[i].result,
                tac[i].arg1,
                tac[i].op,
                tac[i].arg2);
    }

    printf("+----------------------------------------------------+\n\n");
}

void optimizeCode() {
    printf("+----------------------------------------------------+\n");
    printf("| PHASE 5 : CODE OPTIMIZATION                        |\n");
    printf("+----------------------------------------------------+\n");

    for(int i=0;i<tacIndex;i++) {
        if(isNumber(tac[i].arg1) && isNumber(tac[i].arg2)) {

            int a = atoi(tac[i].arg1);
            int b = atoi(tac[i].arg2);
            int result;

            if(strcmp(tac[i].op, "+") == 0)
                result = a + b;
            else if(strcmp(tac[i].op, "-") == 0)
                result = a - b;
            else if(strcmp(tac[i].op, "*") == 0)
                result = a * b;
            else if(strcmp(tac[i].op, "/") == 0)
                result = a / b;
            else
                continue;

            printf("Constant Folding : %s = %d\n", tac[i].result, result);

            sprintf(tac[i].arg1, "%d", result);
            strcpy(tac[i].op, "=");
            strcpy(tac[i].arg2, "");
        }
    }

    printf("\nOptimized Code:\n\n");

    for(int i=0;i<tacIndex;i++) {
        if(strcmp(tac[i].op, "PRINT") == 0)
            printf("print %s\n", tac[i].arg1);

        else if(strcmp(tac[i].op, "=") == 0)
            printf("%s = %s\n", tac[i].result, tac[i].arg1);

        else
            printf("%s = %s %s %s\n",
                tac[i].result,
                tac[i].arg1,
                tac[i].op,
                tac[i].arg2);
    }

    printf("+----------------------------------------------------+\n\n");
}

void generateAssembly() {
    printf("+----------------------------------------------------+\n");
    printf("| PHASE 6 : TARGET CODE GENERATION                   |\n");
    printf("+----------------------------------------------------+\n");

    printf(".data\n");

    for(int i=0;i<symbolCount;i++)
        printf("%s DW 0\n", symbolTable[i].name);

    printf("\n.text\n\n");

    for(int i=0;i<tacIndex;i++) {

        if(strcmp(tac[i].op, "=") == 0) {
            printf("MOV AX, %s\n", tac[i].arg1);
            printf("MOV %s, AX\n", tac[i].result);
        }

        else if(strcmp(tac[i].op, "+") == 0) {
            printf("MOV AX, %s\n", tac[i].arg1);
            printf("ADD AX, %s\n", tac[i].arg2);
            printf("MOV %s, AX\n", tac[i].result);
        }

        else if(strcmp(tac[i].op, "-") == 0) {
            printf("MOV AX, %s\n", tac[i].arg1);
            printf("SUB AX, %s\n", tac[i].arg2);
            printf("MOV %s, AX\n", tac[i].result);
        }

        else if(strcmp(tac[i].op, "*") == 0) {
            printf("MOV AX, %s\n", tac[i].arg1);
            printf("MUL %s\n", tac[i].arg2);
            printf("MOV %s, AX\n", tac[i].result);
        }

        else if(strcmp(tac[i].op, "/") == 0) {
            printf("MOV AX, %s\n", tac[i].arg1);
            printf("DIV %s\n", tac[i].arg2);
            printf("MOV %s, AX\n", tac[i].result);
        }

        else if(strcmp(tac[i].op, "PRINT") == 0) {
            printf("OUT %s\n", tac[i].arg1);
        }
    }

    printf("HLT\n");
    printf("+----------------------------------------------------+\n\n");
}
%}

%union {
    int number;
    char *text;
}

%token <number> NUMBER
%token <text> IDENTIFIER STRING

%token ASSIGN PLUS MINUS MUL DIV
%token EQ NEQ LT GT LEQ GEQ
%token LP RP LB RB SC CM
%token INT PRINT IF ELSE WHILE RETURN

%type <text> expr

%left PLUS MINUS
%left MUL DIV

%%

program:
    program statement
    |
    statement
    ;

statement:
    INT IDENTIFIER ASSIGN expr SC {
        saveRule("statement -> int identifier = expression ;");

        int val = atoi($4);
        addSymbol($2, val);
        generateCode("=", $4, "", $2);
    }

    | IDENTIFIER ASSIGN expr SC {
        saveRule("statement -> identifier = expression ;");

        int val = atoi($3);
        addSymbol($1, val);
        generateCode("=", $3, "", $1);
    }

    | PRINT expr SC {
        saveRule("statement -> print expression ;");

        generateCode("PRINT", $2, "", "");
    }

    | PRINT STRING SC {
        saveRule("statement -> print string ;");

        generateCode("PRINT", $2, "", "");
    }
    ;

expr:
    expr PLUS expr {
        saveRule("expression -> expression + expression");

        char *temp = newTemp();
        generateCode("+", $1, $3, temp);

        int value = atoi($1) + atoi($3);

        char *res = (char*)malloc(20);
        sprintf(res, "%d", value);

        $$ = temp;
    }

    | expr MINUS expr {
        saveRule("expression -> expression - expression");

        char *temp = newTemp();
        generateCode("-", $1, $3, temp);

        $$ = temp;
    }

    | expr MUL expr {
        saveRule("expression -> expression * expression");

        char *temp = newTemp();
        generateCode("*", $1, $3, temp);

        $$ = temp;
    }

    | expr DIV expr {
        saveRule("expression -> expression / expression");

        char *temp = newTemp();
        generateCode("/", $1, $3, temp);

        $$ = temp;
    }

    | NUMBER {
        saveRule("expression -> number");

        char *buffer = (char*)malloc(20);
        sprintf(buffer, "%d", $1);
        $$ = buffer;
    }

    | IDENTIFIER {
        saveRule("expression -> identifier");

        getValue($1);
        $$ = $1;
    }
    ;

%%

void yyerror(const char *s) {
    printf("[SYNTAX ERROR] %s at line %d\n", s, current_line);
}

int main() {

    printf("=====================================================\n");
    printf("              MINI COMPILER SYSTEM                   \n");
    printf("=====================================================\n\n");

    yyparse();

    displayTokens();

    printf("+----------------------------------------------------+\n");
    printf("| PHASE 2 : SYNTAX ANALYSIS                          |\n");
    printf("+----------------------------------------------------+\n");

    for(int i=0;i<syntaxCount;i++)
        printf("Rule %d : %s\n", i+1, syntaxRules[i]);

    printf("+----------------------------------------------------+\n\n");

    printf("+----------------------------------------------------+\n");
    printf("| PHASE 3 : SEMANTIC ANALYSIS                        |\n");
    printf("+----------------------------------------------------+\n");

    if(semanticErrors == 0)
        printf("No Semantic Errors Found\n");

    printf("+----------------------------------------------------+\n\n");

    printf("+----------------------------------------------------+\n");
    printf("| SYMBOL TABLE                                       |\n");
    printf("+----------------+------------+----------------------+\n");
    printf("| Name           | Value      | Scope                |\n");
    printf("+----------------+------------+----------------------+\n");

    for(int i=0;i<symbolCount;i++) {
        printf("| %-14s | %-10d | %-20s |\n",
            symbolTable[i].name,
            symbolTable[i].value,
            "Global");
    }

    printf("+----------------+------------+----------------------+\n\n");

    showTAC();

    optimizeCode();

    generateAssembly();

    printf("=====================================================\n");
    printf("        COMPILATION COMPLETED SUCCESSFULLY           \n");
    printf("=====================================================\n");

    return 0;
}
