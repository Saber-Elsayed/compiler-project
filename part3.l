%{
#include "part3.tab.h"
%}

%%
"def"           { printf("LEX: %s\n", yytext); return DEF; }
"main"          { printf("LEX: %s\n", yytext); return MAIN; }
"__main__"      { printf("LEX: %s\n", yytext); return MAIN; }
"float"         { printf("LEX: %s\n", yytext); return FLOAT; }
"int"           { printf("LEX: %s\n", yytext); return INT; }
"if"            { printf("LEX: %s\n", yytext); return IF; }
"else"          { printf("LEX: %s\n", yytext); return ELSE; }
"return"        { printf("LEX: %s\n", yytext); return RETURN; }
"while"         { printf("LEX: %s\n", yytext); return WHILE; }
"string"        { printf("LEX: %s\n", yytext); return STRING; }
"char"          { printf("LEX: %s\n", yytext); return CHAR; }
"u"             { printf("LEX: %s\n", yytext); return USTRING; }
"bool"          { printf("LEX: %s\n", yytext); return BOOL; }
"true"          { yylval.type = 5; printf("LEX: %s\n", yytext); return TRUE; }
"false"         { yylval.type = 5; printf("LEX: %s\n", yytext); return FALSE; }
"and"           { printf("LEX: %s\n", yytext); return AND; }
"or"            { printf("LEX: %s\n", yytext); return OR; }
     [a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+\.[0-9]+    { yylval.type = 1; printf("LEX: %s\n", yytext); return NUMBER; }
[0-9]+            { yylval.type = 0; printf("LEX: %s\n", yytext); return NUMBER; }
"("             { printf("LEX: %s\n", yytext); return OPENPAREN; }
")"             { printf("LEX: %s\n", yytext); return CLOSEPAREN; }
"{"             { printf("LEX: %s\n", yytext); return OPENBRACE; }
"}"             { printf("LEX: %s\n", yytext); return CLOSEBRACE; }
":"             { printf("LEX: %s\n", yytext); return COLON; }
","             { printf("LEX: %s\n", yytext); return COMMA; }
"->"            { printf("LEX: %s\n", yytext); return ARROW; }
";"             { printf("LEX: %s\n", yytext); return SEMICOLON; }
"=="            { printf("LEX: %s\n", yytext); return EQ; }
"!="            { printf("LEX: %s\n", yytext); return NEQ; }
"<="            { printf("LEX: %s\n", yytext); return LEQ; }
">="            { printf("LEX: %s\n", yytext); return GEQ; }
"="             { printf("LEX: %s\n", yytext); return ASSIGN; }
"<"             { printf("LEX: %s\n", yytext); return LT; }
">"             { printf("LEX: %s\n", yytext); return GT; }
"+"             { printf("LEX: %s\n", yytext); return PLUS; }
"-"             { printf("LEX: %s\n", yytext); return MINUS; }
"*"             { printf("LEX: %s\n", yytext); return MULT; }
"/"             { printf("LEX: %s\n", yytext); return DIV; }
"u"[\"]([^\"]|\\.)*[\"] { yylval.type = 4; printf("LEX: %s\n", yytext); return USTRING; }
[\"]([^\"]|\\.)*[\"] { yylval.type = 2; printf("LEX: %s\n", yytext); return STRING; }
[']([^']|\\.)['] { yylval.type = 3; printf("LEX: %s\n", yytext); return CHAR; }
[ \t\n]+        ;
.               { printf("Unknown: %s\n", yytext); }
%%

int yywrap(void) { return 1; }
