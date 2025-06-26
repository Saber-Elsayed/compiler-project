%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "part3.tab.h"
int yylex();
int yyerror(char *s) { printf("Error: %s\n", s); return 0; }
int main_count = 0;
#define MAX_FUNCS 100
char* function_names[MAX_FUNCS];
int function_param_count[MAX_FUNCS];
int function_count = 0;
#define MAX_VARS 1000
char* var_names[MAX_VARS];
int var_types[MAX_VARS]; // 0 = int, 1 = float
int var_count = 0;
int error_flag = 0;
int temp_counter = 0;
int label_counter = 0;
#define MAX_TAC_LINES 5000
char* tac_lines[MAX_TAC_LINES];
int tac_count = 0;

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
    if (var_count >= MAX_VARS) {
        printf("Error: Too many variables declared\n");
        exit(1);
    }
    for (int i = 0; i < var_count; ++i) {
        if (strcmp(var_names[i], name) == 0) {
            return 0; // קיים כבר
        }
    }
    var_names[var_count] = strdup(name);
    if (!var_names[var_count]) {
        printf("Error: malloc failed in add_var_name\n");
        exit(1);
    }
    var_types[var_count] = type;
    var_count++;
    if (var_count > MAX_VARS) {
        printf("Error: var_count overflow\n");
        exit(1);
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

char* new_temp() {
    char* buf = malloc(10);
    if (!buf) {
        printf("Error: malloc failed in new_temp\n");
        exit(1);
    }
    sprintf(buf, "t%d", temp_counter++);
    return buf;
}

char* new_label() {
    char* buf = malloc(10);
    if (!buf) {
        printf("Error: malloc failed in new_label\n");
        exit(1);
    }
    sprintf(buf, "L%d", ++label_counter);
    return buf;
}

void emit(const char* fmt, ...) {
    if (tac_count >= MAX_TAC_LINES) {
        printf("Error: Too many TAC lines\n");
        exit(1);
    }
    va_list args;
    va_start(args, fmt);
    char* buf = malloc(256);
    if (!buf) {
        printf("Error: malloc failed in emit\n");
        exit(1);
    }
    vsnprintf(buf, 256, fmt, args);
    tac_lines[tac_count++] = buf;
    if (tac_count > MAX_TAC_LINES) {
        printf("Error: tac_count overflow\n");
        exit(1);
    }
    va_end(args);
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
%token NOT

%union {
    char* str;
    int ival;
    int type;
    char* code;
    struct {
        int type;
        char* temp;
        char* code;
    } exprval;
}
%token <str> IDENTIFIER

%type <str> id_list
%type <str> decl
%type <str> param_list
%type <str> arg_list
%type <type> type
%type <exprval> expr condition
%type <code> stmts stmt assign_stmt if_stmt while_stmt return_stmt
%%
program: function_list { printf("Parsing OK\n"); }
       ;

function_list: function_list function
             | /* empty */
             ;

function: DEF IDENTIFIER OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    printf("%s:\n BeginFunc 20\n%sEndFunc\n", $2, $10);
}
| DEF IDENTIFIER OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    printf("%s:\n BeginFunc 20\n%sEndFunc\n", $2, $7);
}
| DEF MAIN OPENPAREN param_list CLOSEPAREN ARROW type COLON OPENBRACE stmts CLOSEBRACE {
    printf("main:\n BeginFunc 24\n%sEndFunc\n", $10);
}
| DEF MAIN OPENPAREN CLOSEPAREN COLON OPENBRACE stmts CLOSEBRACE {
    printf("main:\n BeginFunc 24\n%sEndFunc\n", $7);
}
;

param_list: param { $$ = strdup(""); }
          | param COMMA param_list { $$ = strdup(""); }
          | /* empty */ { $$ = strdup(""); }
          ;

param: FLOAT IDENTIFIER
     | INT IDENTIFIER
     ;

stmts: stmt stmts {
    asprintf(&$$, "%s%s", $1, $2);
}
| /* empty */ {
    $$ = strdup("");
}

stmt: decl
    | assign_stmt { $$ = $1; }
    | if_stmt { $$ = $1; }
    | while_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    | expr SEMICOLON { $$ = $1.code; }
    ;

decl: type id_list SEMICOLON {
    if ($2 == NULL) {
        printf("Error: NULL id_list in decl\n");
        exit(1);
    }
    char* ids = strdup($2);
    if (!ids) {
        printf("Error: malloc failed in decl (strdup)\n");
        exit(1);
    }
    char* token = strtok(ids, ",");
    while (token != NULL) {
        if (strlen(token) == 0) {
            printf("Error: Empty variable name in decl\n");
            free(ids);
            exit(1);
        }
        if (!add_var_name(token, $1)) {
            printf("Semantic Error: Duplicate variable name: %s\n", token);
        }
        token = strtok(NULL, ",");
    }
    free(ids);
    $$ = strdup("");
}

id_list: IDENTIFIER {
    if ($1 == NULL) {
        printf("Error: NULL identifier in id_list\n");
        exit(1);
    }
    $$ = strdup($1);
    if (!$$) {
        printf("Error: malloc failed in id_list (IDENTIFIER)\n");
        exit(1);
    }
}
| IDENTIFIER COMMA id_list {
    if ($1 == NULL || $3 == NULL) {
        printf("Error: NULL identifier in id_list (COMMA)\n");
        exit(1);
    }
    int len = strlen($1) + strlen($3) + 2; // 1 for comma, 1 for \0
    $$ = malloc(len);
    if (!$$) {
        printf("Error: malloc failed in id_list (COMMA)\n");
        exit(1);
    }
    snprintf($$, len, "%s,%s", $1, $3);
}

assign_stmt: IDENTIFIER ASSIGN expr SEMICOLON {
    asprintf(&$$, "%s%s = %s\n", $3.code, $1, $3.temp);
}

if_stmt: IF expr COLON stmt ELSE COLON stmt {
    char* l1 = new_label();
    char* l2 = new_label();
    char* l3 = new_label();
    asprintf(&$$, "%sif %s Goto %s\nGoto %s\n%s: %sGoto %s\n%s: %sGoto %s\n%s:\n", $2.code, $2.temp, l1, l2, l1, $4, l3, l2, $7, l3, l3);
}

while_stmt: WHILE expr COLON OPENBRACE stmts CLOSEBRACE {
    char* l_start = new_label();
    char* l_body = new_label();
    char* l_exit = new_label();
    asprintf(&$$, "%s:\n%sif %s Goto %s\nGoto %s\n%s: %sGoto %s\n%s:\n", l_start, $2.code, $2.temp, l_body, l_exit, l_body, $5, l_start, l_exit);
}

return_stmt: RETURN expr SEMICOLON {
    if ($2.temp == NULL) $2.temp = strdup("");
    if ($2.code == NULL) $2.code = strdup("");
    if (asprintf(&$$, "%sReturn %s\n", $2.code, $2.temp) == -1) {
        printf("Error: asprintf failed\n");
        exit(1);
    }
}

type: INT { $$ = 0; }
    | FLOAT { $$ = 1; }
    | STRING { $$ = 2; }
    | CHAR { $$ = 3; }
    | USTRING { $$ = 4; }
    | BOOL { $$ = 5; }
    ;

expr: NUMBER {
    $$.type = 0;
    $$.temp = new_temp();
    if (asprintf(&$$.code, "%s = %d\n", $$.temp, $1) == -1) {
        printf("Error: asprintf failed\n");
        exit(1);
    }
}
| STRING {
    $$.type = 2;
    $$.temp = strdup("");
    $$.code = strdup("");
}
| CHAR {
    $$.type = 3;
    $$.temp = strdup("");
    $$.code = strdup("");
}
| USTRING {
    $$.type = 4;
    $$.temp = strdup("");
    $$.code = strdup("");
}
| TRUE {
    $$.type = 5;
    $$.temp = strdup("true");
    $$.code = strdup("");
}
| FALSE {
    $$.type = 5;
    $$.temp = strdup("false");
    $$.code = strdup("");
}
| IDENTIFIER {
    if (!is_var_defined($1)) {
        printf("Semantic Error: Use of undefined variable: %s\n", $1);
        $$.type = -1;
        $$.temp = strdup("");
        $$.code = strdup("");
    } else {
        $$.type = get_var_type($1);
        $$.temp = strdup($1);
        $$.code = strdup("");
    }
}
| expr EQ expr {
    $$.type = 5;
    $$.temp = new_temp();
    asprintf(&$$.code, "%s%s%s = %s == %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
}
| expr NEQ expr {
    if ($1.type == $3.type) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s != %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Operand types for '!=' must match\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| NOT expr {
    if ($2.type == 5) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = !%s\n", $$.code, $2.code, $$.temp, $2.temp);
    } else {
        printf("Semantic Error: 'not' operator requires bool operand\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr PLUS expr {
    if ($1.temp == NULL) $1.temp = strdup("");
    if ($3.temp == NULL) $3.temp = strdup("");
    if ($1.code == NULL) $1.code = strdup("");
    if ($3.code == NULL) $3.code = strdup("");
    $$.type = ($1.type == 1 || $3.type == 1) ? 1 : 0;
    $$.temp = new_temp();
    if (asprintf(&$$.code, "%s%s%s = %s + %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp) == -1) {
        printf("Error: asprintf failed\n");
        exit(1);
    }
}
| expr MINUS expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = ($1.type == 1 || $3.type == 1) ? 1 : 0;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s - %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '-'\n");
        $$.type = -1;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr MULT expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = ($1.type == 1 || $3.type == 1) ? 1 : 0;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s * %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '*'\n");
        $$.type = -1;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr DIV expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = 1;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s / %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '/'\n");
        $$.type = -1;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr AND expr {
    if ($1.type == 5 && $3.type == 5) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s && %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for 'and' (must be bool)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr OR expr {
    if ($1.type == 5 && $3.type == 5) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s || %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for 'or' (must be bool)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
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
    $$.type = 0; // ברירת מחדל int
    $$.temp = strdup("");
}
| OPENPAREN expr CLOSEPAREN {
    if ($2.temp == NULL) $2.temp = strdup("");
    $$.type = $2.type;
    $$.temp = $2.temp;
}
| expr LT expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s < %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '<' (must be int or float)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr LEQ expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s <= %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '<=' (must be int or float)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr GT expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s > %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '>' (must be int or float)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
| expr GEQ expr {
    if (($1.type == 0 || $1.type == 1) && ($3.type == 0 || $3.type == 1)) {
        $$.type = 5;
        $$.temp = new_temp();
        asprintf(&$$.code, "%s%s%s = %s >= %s\n", $1.code, $3.code, $$.temp, $1.temp, $3.temp);
    } else {
        printf("Semantic Error: Invalid operand types for '>=' (must be int or float)\n");
        $$.type = 5;
        $$.temp = strdup("");
        $$.code = strdup("");
    }
}
;

arg_list: expr {
    if ($1.temp == NULL) $1.temp = strdup("");
    int len = strlen($1.temp) + 2;
    $$ = malloc(len);
    if (!$$) {
        printf("Error: malloc failed in arg_list (single)\n");
        exit(1);
    }
    snprintf($$, len, "1");
}
| expr COMMA arg_list {
    if ($1.temp == NULL) $1.temp = strdup("");
    int len = strlen($3) + 3; // $3 הוא str
    $$ = malloc(len);
    if (!$$) {
        printf("Error: malloc failed in arg_list (comma)\n");
        exit(1);
    }
    snprintf($$, len, "1,%s", $3);
}
| /* empty */ {
    $$ = strdup("");
    if (!$$) {
        printf("Error: malloc failed in arg_list (empty)\n");
        exit(1);
    }
}
%%
int main() {
    yyparse();
    if (!error_flag) {
        for (int i = 0; i < tac_count; ++i) {
            printf("%s\n", tac_lines[i]);
            free(tac_lines[i]);
        }
    }
    return 0;
}

