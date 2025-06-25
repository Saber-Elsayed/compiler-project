%{
#include <stdio.h>
#include "part3.tab.h"
int yylex();
int yyerror(char *s) { printf("Error: %s\n", s); return 0; }
int main_count = 0;
#define MAX_FUNCS 100
char* function_names[MAX_FUNCS];
int function_count = 0;
#define MAX_VARS 100
char* var_names[MAX_VARS];
int var_count = 0;

int add_function_name(const char* name) {
    for (int i = 0; i < function_count; ++i) {
        if (strcmp(function_names[i], name) == 0) {
            return 0; // קיים כבר
        }
    }
    if (function_count < MAX_FUNCS) {
        function_names[function_count++] = strdup(name);
    }
    return 1; // נוסף בהצלחה
}

void reset_var_table() {
    for (int i = 0; i < var_count; ++i) {
        free(var_names[i]);
    }
    var_count = 0;
}

int add_var_name(const char* name) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return 0; // קיים כבר
        }
    }
    if (var_count < MAX_VARS) {
        var_names[var_count++] = strdup(name);
    }
    return 1; // נוסף בהצלחה
}
%}

%left PLUS MINUS
%left MULT DIV
%left EQ NEQ LT GT LEQ GEQ
%token DEF MAIN FLOAT INT IDENTIFIER NUMBER
%token OPENPAREN CLOSEPAREN OPENBRACE CLOSEBRACE COLON ARROW SEMICOLON COMMA
%token ASSIGN PLUS MINUS MULT DIV
%token IF ELSE EQ NEQ LT GT LEQ GEQ
%token RETURN WHILE

%union {
    char* str;
    int ival;
}
%token <str> IDENTIFIER

%%
program: function_list { printf("Parsing OK\n"); }
       ;

function_list: function_list function
             | /* empty */
             ;

function: DEF IDENTIFIER OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    if (strcmp($2, "__main__") == 0) {
        printf("Semantic Error: main/__main__ must not have parameters or return type\n");
    }
    if (!add_function_name($2)) {
        printf("Semantic Error: Duplicate function name: %s\n", $2);
    }
}
| DEF IDENTIFIER OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    if (strcmp($2, "__main__") == 0) {
        main_count++;
        if (main_count > 1) {
            printf("Semantic Error: Multiple definitions of main\n");
        }
    }
    if (!add_function_name($2)) {
        printf("Semantic Error: Duplicate function name: %s\n", $2);
    }
}
| DEF MAIN OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    printf("Semantic Error: main/__main__ must not have parameters or return type\n");
    if (!add_function_name("main")) {
        printf("Semantic Error: Duplicate function name: main\n");
    }
}
| DEF MAIN OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    main_count++;
    if (main_count > 1) {
        printf("Semantic Error: Multiple definitions of main\n");
    }
    if (!add_function_name("main")) {
        printf("Semantic Error: Duplicate function name: main\n");
    }
}
;

param_list: param
          | param COMMA param_list
          | /* empty */
          ;

param: FLOAT IDENTIFIER
     | INT IDENTIFIER
     ;

stmts: stmt stmts
     | /* empty */
     ;

stmt: decl
    | assign_stmt
    | if_stmt
    | while_stmt
    | return_stmt
    ;

decl: type id_list SEMICOLON {
    char* ids = $2;
    char* token = strtok(ids, ",");
    while (token != NULL) {
        if (!add_var_name(token)) {
            printf("Semantic Error: Duplicate variable name: %s\n", token);
        }
        token = strtok(NULL, ",");
    }
}

id_list: IDENTIFIER {
    $$ = strdup($1);
}
| IDENTIFIER COMMA id_list {
    int len = strlen($1) + strlen($3) + 2;
    $$ = malloc(len);
    snprintf($$, len, "%s,%s", $1, $3);
}

assign_stmt: IDENTIFIER ASSIGN expr SEMICOLON
           ;

if_stmt: IF condition COLON stmt
       | IF condition COLON stmt ELSE COLON stmt
       ;
while_stmt: WHILE condition COLON OPENBRACE stmts CLOSEBRACE
          ;

return_stmt: RETURN expr SEMICOLON
           ;

condition: expr EQ expr
         | expr NEQ expr
         | expr LT expr
         | expr GT expr
         | expr LEQ expr
         | expr GEQ expr
         ;

type: INT
    | FLOAT
    ;

expr: NUMBER
    | IDENTIFIER
    | expr PLUS expr
    | expr MINUS expr
    | expr MULT expr
    | expr DIV expr
    | IDENTIFIER OPENPAREN arg_list CLOSEPAREN
    | OPENPAREN expr CLOSEPAREN
    ;

arg_list: expr
        | expr COMMA arg_list
        | /* empty */
        ;
%%
int main() {
    yyparse();
    return 0;
}
