%{
	#include "y.tab.h"

	int lineNo = 1;
	int colNo = 1;
%}

%%
"program"		{ yylloc.first_line = lineNo ; yylloc.first_column = colNo ;colNo+=7; return TOK_PROGRAM ;} 
"var"			{ yylloc.first_line = lineNo ; yylloc.first_column = colNo ;colNo+=3; return TOK_VAR; }
"begin"			{ yylloc.first_line = lineNo ; yylloc.first_column = colNo ;colNo+=5; return TOK_BEGIN; }
"end"			{ yylloc.first_line = lineNo ; yylloc.first_column = colNo ;colNo+=3; return TOK_END; }
"read" 			{ colNo+=4; return TOK_READ; }
"write"			{ colNo+=5; return TOK_WRITE; }
"for"			{ colNo+=3; return TOK_FOR; }
"do" 			{ colNo+=2; return TOK_DO; }
"to"			{ colNo+=2; return TOK_TO; }
"integer"		{ colNo+=7; return TOK_INTEGER; }
[a-zA-Z][a-zA-Z0-9_]* { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_ID; }
";"				{ colNo++; return ';'; }  
":"				{ colNo++; return ':'; }
","  			{ colNo++; return ','; }
":="			{ colNo++; return TOK_EQUALS; }
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MULTIPLY; }
"/"				{ colNo++; return TOK_DIVIDE; }
"("				{ colNo++; return '('; }
")"				{ colNo++; return ')'; }
"."			{ colNo++; return '.'; }

0|[1-9][0-9]*	{ 	
					yylloc.first_line = lineNo;
					yylloc.first_column = colNo;
					colNo+=strlen(yytext);
					yylval.val = atoi(yytext);

				    return TOK_INT; }


[ ]				{ colNo++; }
\r\n			{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{  printf ("Eoare lexicala%d %d :atomul lexical \"%s\" nedefinit \n" ,lineNo,colNo,yytext); yylloc.first_line = lineNo ;yylloc.first_column= colNo ; } //daca secventa lexicala nu va potrivi niciun atom lexical din gr. limbajului  el va potrivi TOK_ERROR 
	
%%
