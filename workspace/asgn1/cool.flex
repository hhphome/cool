/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 *  to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <errno.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
LE              <=
BOOL_CONST      (t[Rr][Uu][Ee]|f[Aa][Ll][Ss][Ee])
DIGIT           [0-9]
INTEGER         {DIGIT}+
LETTER          [a-zA-Z]
LETTERS          {LETTER}+
ID              ({LETTERS}|_)+({LETTERS}|{DIGIT}|_)+
BLANK           [\ \f\r\t\v]+

%%
 /*
  * Rules section
  */

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */

\.  {return '.';}
\@  {return '@';}
\~  {return '~';}

{BLANK} {}

{INTEGER} {
    cool_yylval.symbol = inttable.add_string(yytext);
    }

class {return (CLASS);}

else {return (ELSE);}

if {return (IF);}

fi {return (FI);}

in {return (IN);}

inherits {return (INHERITS);}

let {return (LET);}

loop {return (LOOP);}

pool {return (POOL);}

then {return (THEN);}

while {return (WHILE);}

case {return (CASE);}

esac {return (ESAC);}

of {return (OF);}

{DARROW} { return (DARROW); }

new {return (NEW);}

isvoid {return (ISVOID);}

\"[^"]* {
    //Handle string
    if (yytext[yyleng - 1] == '\\')
        yymore();
    else{
        // ??? how to pick up the final quote " ???
        char c = 0;
        c = yyinput();
        if(c != '"'){
            //TODO: miss finishing quote
            printf("miss finishing quote\n");
            return (ERROR);
        } 
        //have finishing quote
        //+1 to ignore the starting '"'.
        cool_yylval.symbol = stringtable.add_string(yytext+1);
        return (STR_CONST);
    }
    }

"(*" {
       char c = 0;
       for(;;){
           //throw away everything in comments
           while( (c = yyinput()) != '*' && c != EOF); 

           if(c == '*'){
               while((c = yyinput()) == '*');
               if(c == ')') break; 
           }

           if(c == EOF)
           {
               //EOF in comment
               perror("EOF in comment");
               return(ERROR);
           }
       }
    }

\; {return ';';}

\: {return ':';}

\{ {return '{';}

\} {return '}';}

\(  { return '('; }

\)  { return ')'; }
    
\[  { return '['; }

\]  { return ']'; }

\* { return '*'; }

\/ { return '/'; }

\+ { return '+'; }

\- { return '-'; }



INTEGER {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (INT_CONST);
    }

{BOOL_CONST} { 
    cool_yylval.symbol = stringtable.add_string(yytext); 
    return (BOOL_CONST); }

typeid {return (TYPEID);}

objectid {return (OBJECTID);}

"<-" {return (ASSIGN);}

not {return (NOT);}

{LE} {return (LE);}

{ID} {
    cool_yylval.symbol = idtable.add_string(yytext);
    }

ERROR { return (ERROR);}

let_stmt {return (LET_STMT);}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */



