/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PART3_TAB_H_INCLUDED
# define YY_YY_PART3_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    DEF = 258,                     /* DEF  */
    MAIN = 259,                    /* MAIN  */
    FLOAT = 260,                   /* FLOAT  */
    INT = 261,                     /* INT  */
    STRING = 262,                  /* STRING  */
    CHAR = 263,                    /* CHAR  */
    USTRING = 264,                 /* USTRING  */
    NUMBER = 265,                  /* NUMBER  */
    OPENPAREN = 266,               /* OPENPAREN  */
    CLOSEPAREN = 267,              /* CLOSEPAREN  */
    OPENBRACE = 268,               /* OPENBRACE  */
    CLOSEBRACE = 269,              /* CLOSEBRACE  */
    COLON = 270,                   /* COLON  */
    ARROW = 271,                   /* ARROW  */
    SEMICOLON = 272,               /* SEMICOLON  */
    COMMA = 273,                   /* COMMA  */
    ASSIGN = 274,                  /* ASSIGN  */
    PLUS = 275,                    /* PLUS  */
    MINUS = 276,                   /* MINUS  */
    MULT = 277,                    /* MULT  */
    DIV = 278,                     /* DIV  */
    IF = 279,                      /* IF  */
    ELSE = 280,                    /* ELSE  */
    EQ = 281,                      /* EQ  */
    NEQ = 282,                     /* NEQ  */
    LT = 283,                      /* LT  */
    GT = 284,                      /* GT  */
    LEQ = 285,                     /* LEQ  */
    GEQ = 286,                     /* GEQ  */
    RETURN = 287,                  /* RETURN  */
    WHILE = 288,                   /* WHILE  */
    BOOL = 289,                    /* BOOL  */
    TRUE = 290,                    /* TRUE  */
    FALSE = 291,                   /* FALSE  */
    AND = 292,                     /* AND  */
    OR = 293,                      /* OR  */
    IDENTIFIER = 294               /* IDENTIFIER  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 101 "part3.y"

    char* str;
    int ival;
    int type; // 0=int, 1=float

#line 109 "part3.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PART3_TAB_H_INCLUDED  */
