
/* Automatically track line numbers */
%option yylineno 
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>

#include "part3_helpers.hpp"
#include "new_project.tab.hpp"


using namespace std;

extern YYSTYPE yylval;
%}
/* Identifiers start with letter/underscore */
id              [a-zA-Z_][a-zA-Z0-9_]*     

/* Integer numbers */
integernum      [0-9]+      

/* Real numbers with decimal point */
realnum         [0-9]+\.[0-9]+           

/* String literals with escape sequences */  
string_literal  \"([^\"\n\r\\]|\\[\"nt])*\" 

/* Relational operators */
relop           ==|<>|<|>|<=|>=   

/* Addition operators */
addop           [+-]                

/* Multiplication operators */        
mulop           [*/]          

/* Assignment operator */
assign          =        
 
/* Logical AND */                   
and             \&\&   
                    
/* Logical OR */                    
or              \|\|     

/* Logical NOT */
not             !  

/* Variadic function indicator */                        
ellipsis        \.\.\.           

/* Comma separator */
comma           ,    

/* Statement terminator */
semi_colon      ; 

 /* Left parenthesis */
l_paren         \(                         

/* Right parenthesis */
r_paren         \)    

/* Left brace */
l_brace         \{      

/* Right brace */                    
r_brace         \}    

 /* Colon for type declarations */
colon           :               

 /* Single-line comments */
comment         #[^\n\r]*                  

%%
"int"           { yylval.name = strdup("INT"); return INT; }
"float"         { yylval.name = strdup("FLOAT"); return FLOAT; }
"void"          { yylval.name = strdup("VOID"); return VOID; }
"write"         { yylval.name = strdup("WRITE"); return WRITE; }
"read"          { yylval.name = strdup("READ"); return READ; }
"va_arg"        { yylval.name = strdup("VA_ARG"); return VA_ARG; }
"while"         { yylval.name = strdup("WHILE"); return WHILE; }
"do"            { yylval.name = strdup("DO"); return DO; }
"if"            { yylval.name = strdup("IF"); return IF; }
"then"          { yylval.name = strdup("THEN"); return THEN; }
"else"          { yylval.name = strdup("ELSE"); return ELSE; }
"return"        { yylval.name = strdup("RETURN"); return RETURN; }

{id}            { yylval.name = strdup(yytext); return ID; }
{integernum}    { yylval.name = strdup(yytext); return INTEGERNUM; }
{realnum}       { yylval.name = strdup(yytext); return REALNUM; }
{relop}         { yylval.name = strdup(yytext); return RELOP; }
{addop}         { yylval.name = strdup(yytext); return ADDOP; }
{mulop}         { yylval.name = strdup(yytext); return MULOP; }

{comma}         { return COMMA; }
{semi_colon}    { return SEMICOLON; }
{l_paren}       { return LPAREN; }
{r_paren}       { return RPAREN; }
{l_brace}       { return LBRACE; }
{r_brace}       { return RBRACE; }
{colon}         { return COLON; }
{assign}        { return ASSIGN; }
{and}           { return AND; }
{or}            { return OR; }
{not}           { return NOT; }
{ellipsis}      { return ELLIPSIS; }

{string_literal} { /* String Literal Handling */
                  /* Return the entire string (including quotes) as one token. */
                      yylval.name = strdup(yytext);
                      return STRING_LITERAL;
                }

{comment}       { /* ignore comments */ }
      
[ \t\r\n]+      { /* ignore whitespace or newline */ }
.        				{
                  cerr << "Lexical error: '" << yytext << "' in line number " << yylineno << endl;
                  exit(LEXICAL_ERROR);
                }
%%