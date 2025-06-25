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
     [a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+(\.[0-9]+)? { printf("LEX: %s\n", yytext); return NUMBER; }
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
[ \t\n]+        ;
.               { printf("Unknown: %s\n", yytext); }
%%