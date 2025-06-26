%{
#include <stdio.h>
#include <string.h>
#include "part3.tab.h"
#define _GNU_SOURCE
int yylex();
int yyerror(char *s) { printf("Error: %s\n", s); return 0; }
int main_count = 0;
#define MAX_FUNCS 100
char* function_names[MAX_FUNCS];
int function_param_count[MAX_FUNCS];
int function_count = 0;
#define MAX_VARS 100
char* var_names[MAX_VARS];
int var_types[MAX_VARS]; // 0 = int, 1 = float
int var_count = 0;

int add_function_name(const char* name, int param_count) {
    for (int i = 0; i < function_count; ++i) {
        if (strcmp(function_names[i], name) == 0) {
            return 0; // קיים כבר
        }
    }
    if (function_count < MAX_FUNCS) {
        function_names[function_count] = strdup(name);
        function_param_count[function_count] = param_count;
        function_count++;
    }
    return 1; // נוסף בהצלחה
}

void reset_var_table() {
    for (int i = 0; i < var_count; ++i) {
        free(var_names[i]);
    }
    var_count = 0;
}

int add_var_name(const char* name, int type) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return 0; // קיים כבר
        }
    }
    if (var_count < MAX_VARS) {
        var_names[var_count] = strdup(name);
        var_types[var_count] = type;
        var_count++;
    }
    return 1; // נוסף בהצלחה
}

int is_var_defined(const char* name) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return 1;
        }
    }
    return 0;
}

int get_var_type(const char* name) {
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return var_types[i];
        }
    }
    return -1; // לא קיים
}

int count_params(char* ids) {
    if (!ids || strlen(ids) == 0) return 0;
    int count = 1;
    for (char* p = ids; *p; ++p) {
        if (*p == ',') count++;
    }
    return count;
}

int count_args(char* ids) {
    if (!ids || strlen(ids) == 0) return 0;
    int count = 1;
    for (char* p = ids; *p; ++p) {
        if (*p == ',') count++;
    }
    return count;
}
%}

%left PLUS MINUS
%left MULT DIV
%left EQ NEQ LT GT LEQ GEQ
%token DEF MAIN FLOAT INT STRING CHAR USTRING
%token <type> NUMBER
%token OPENPAREN CLOSEPAREN OPENBRACE CLOSEBRACE COLON ARROW SEMICOLON COMMA
%token ASSIGN PLUS MINUS MULT DIV
%token IF ELSE EQ NEQ LT GT LEQ GEQ
%token RETURN WHILE
%token BOOL TRUE FALSE AND OR

%union {
    char* str;
    int ival;
    int type; // 0=int, 1=float
}
%token <str> IDENTIFIER

%type <str> id_list
%type <str> decl
%type <str> param_list
%type <str> arg_list
%type <type> type
%type <type> expr
%type <type> condition
%%
program: function_list { printf("Parsing OK\n"); }
       ;

function_list: function_list function
             | /* empty */
             ;

function: DEF IDENTIFIER OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    int paramc = count_params($4);
    if (strcmp($2, "__main__") == 0) {
        printf("Semantic Error: main/__main__ must not have parameters or return type\n");
    }
    if (!add_function_name($2, paramc)) {
        printf("Semantic Error: Duplicate function name: %s\n", $2);
    }
}
| DEF IDENTIFIER OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    int paramc = 0;
    if (strcmp($2, "__main__") == 0) {
        main_count++;
        if (main_count > 1) {
            printf("Semantic Error: Multiple definitions of main\n");
        }
    }
    if (!add_function_name($2, paramc)) {
        printf("Semantic Error: Duplicate function name: %s\n", $2);
    }
}
| DEF MAIN OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    int paramc = count_params($4);
    printf("Semantic Error: main/__main__ must not have parameters or return type\n");
    if (!add_function_name("main", paramc)) {
        printf("Semantic Error: Duplicate function name: main\n");
    }
}
| DEF MAIN OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    reset_var_table();
    int paramc = 0;
    main_count++;
    if (main_count > 1) {
        printf("Semantic Error: Multiple definitions of main\n");
    }
    if (!add_function_name("main", paramc)) {
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
    | expr SEMICOLON
    ;

decl: type id_list SEMICOLON {
    char* ids = $2;
    char* token = strtok(ids, ",");
    while (token != NULL) {
        if (!add_var_name(token, $1)) {
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

assign_stmt: IDENTIFIER ASSIGN expr SEMICOLON {
    if (!is_var_defined($1)) {
        printf("Semantic Error: Use of undefined variable: %s\n", $1);
    } else {
        int var_type = get_var_type($1);
        int expr_type = $3;
        if (var_type != expr_type) {
            printf("Semantic Error: Type mismatch in assignment to variable '%s'\n", $1);
        }
    }
}

if_stmt: IF condition COLON stmt
       | IF condition COLON stmt ELSE COLON stmt
       ;
while_stmt: WHILE condition COLON OPENBRACE stmts CLOSEBRACE
          ;

return_stmt: RETURN expr SEMICOLON
           ;

condition: expr { $$ = $1; }

type: INT { $$ = 0; }
    | FLOAT { $$ = 1; }
    | STRING { $$ = 2; }
    | CHAR { $$ = 3; }
    | USTRING { $$ = 4; }
    | BOOL { $$ = 5; }
    ;

expr: NUMBER { $$ = $1; }
    | STRING { $$ = 2; }
    | CHAR { $$ = 3; }
    | USTRING { $$ = 4; }
    | TRUE { $$ = 5; }
    | FALSE { $$ = 5; }
    | IDENTIFIER {
        if (!is_var_defined($1)) {
            printf("Semantic Error: Use of undefined variable: %s\n", $1);
            $$ = 0; // ברירת מחדל
        } else {
            $$ = get_var_type($1);
        }
    }
    | expr PLUS expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = ($1 == 0 && $3 == 0) ? 0 : 1;
        } else if ($1 == 2 && $3 == 2) {
            $$ = 2; // string + string
        } else if ($1 == 4 && $3 == 4) {
            $$ = 4; // ustring + ustring
        } else if (($1 == 2 && $3 == 4) || ($1 == 4 && $3 == 2)) {
            $$ = 2; // string + ustring
        } else if ($1 == 3 && $3 == 3) {
            $$ = 2; // char + char
        } else {
            printf("Semantic Error: Invalid operand types for '+'\n");
            $$ = 0;
        }
    }
    | expr MINUS expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = ($1 == 0 && $3 == 0) ? 0 : 1;
        } else {
            printf("Semantic Error: Invalid operand types for '-'\n");
            $$ = 0;
        }
    }
    | expr MULT expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = ($1 == 0 && $3 == 0) ? 0 : 1;
        } else {
            printf("Semantic Error: Invalid operand types for '*'\n");
            $$ = 0;
        }
    }
    | expr DIV expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = 1; // חילוק תמיד מחזיר float
        } else {
            printf("Semantic Error: Invalid operand types for '/'\n");
            $$ = 1;
        }
    }
    | expr AND expr {
        if ($1 == 5 && $3 == 5) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for 'and' (must be bool)\n");
            $$ = 5;
        }
    }
    | expr OR expr {
        if ($1 == 5 && $3 == 5) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for 'or' (must be bool)\n");
            $$ = 5;
        }
    }
    | IDENTIFIER OPENPAREN arg_list CLOSEPAREN {
        int found = 0;
        int paramc = 0;
        int argc = count_args($3);
        for (int i = 0; i < function_count; ++i) {
            if (strcmp(function_names[i], $1) == 0) {
                found = 1;
                paramc = function_param_count[i];
                break;
            }
        }
        if (!found) {
            printf("Semantic Error: Call to undefined function: %s\n", $1);
        } else if (argc > paramc) {
            printf("Semantic Error: Too many arguments in call to function: %s\n", $1);
        }
        $$ = 0; // ברירת מחדל int
    }
    | OPENPAREN expr CLOSEPAREN { $$ = $2; }
    | expr LT expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for '<' (must be int or float)\n");
            $$ = 5;
        }
    }
    | expr LEQ expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for '<=' (must be int or float)\n");
            $$ = 5;
        }
    }
    | expr GT expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for '>' (must be int or float)\n");
            $$ = 5;
        }
    }
    | expr GEQ expr {
        if (($1 == 0 || $1 == 1) && ($3 == 0 || $3 == 1)) {
            $$ = 5;
        } else {
            printf("Semantic Error: Invalid operand types for '>=' (must be int or float)\n");
            $$ = 5;
        }
    }
    ;

arg_list: expr {
    $$ = strdup("");
    strcat($$, "1");
}
| expr COMMA arg_list {
    $$ = strdup("");
    strcat($$, "1,");
    strcat($$, $3);
}
| /* empty */ {
    $$ = strdup("");
}
%%
int main() {
    yyparse();
    return 0;
}

