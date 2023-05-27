%token TK_ID                   1
%token TK_INT                  2
%token TK_CHAR                 3
%token TK_STR                  4
%token TK_COMMA                5
%token TK_PLUS                 6
%token TK_MINUS                7
%token TK_MULTI                8
%token TK_ASSGN                9
%token TK_LT                   10
%token TK_LE                   11
%token TK_EQ                   12
%token TK_NE                   13
%token TK_GT                   14
%token TK_GE                   15
%token TK_COL                  16
%token TK_THEN                 17
%token TK_ELSE                 18
%token TK_BRACKET_OPEN         19
%token TK_BRACKET_CLOSE        20
%token TK_PAR_OPEN             21
%token TK_PAR_CLOSE            22
%token KEYW_AND                23
%token KEYW_BOOLEAN            24
%token KEYW_CHAR               25
%token KEYW_DIV                26
%token KEYW_DO                 27
%token KEYW_END                28
%token KEYW_FALSE              29
%token KEYW_FUNCTION           30
%token KEYW_IF                 31
%token KEYW_INTEGER            32
%token KEYW_IS                 33
%token KEYW_MOD                34
%token KEYW_NOT                35
%token KEYW_OR                 36
%token KEYW_REF                37
%token KEYW_RETURN             38
%token KEYW_STRING             39
%token KEYW_TRUE               40
%token KEYW_VAR                41

%right TK_BRACKET_OPEN
%left TK_EQ,TK_NE,TK_GT,TK_LT,TK_GE,TK_LE
%left TK_PLUS,TK_MINUS,KEYW_OR
%left TK_MULTI,KEYW_DIV,KEYW_MOD,KEYW_AND
%left UNARY

%%

program:		function_body
;

function_body:		  fdef statement
;

variable_def:		  KEYW_VAR id_list TK_COL type_name
;

id_list:		  TK_ID
			| id_list TK_COMMA TK_ID
;

type_name:		  KEYW_INTEGER
			| KEYW_BOOLEAN
			| KEYW_CHAR
			| KEYW_STRING
;

parameter_list:		/* empty */
			| parameter 
			| parameter_list TK_COMMA parameter
;

parameter:		  TK_ID TK_COL type_name
			| TK_ID TK_COL KEYW_REF type_name
;

statement:		/* empty */
			| l_value TK_ASSGN expression statement
			| KEYW_IF condition_list KEYW_END statement
			| KEYW_DO condition_list KEYW_END statement
			| function_call statement
			| KEYW_RETURN 
			| KEYW_RETURN TK_PAR_OPEN expression TK_PAR_CLOSE
;

condition_list:		  condition
			| condition_list TK_ELSE condition
;

condition:		  expression TK_THEN statement
;

expression:		  expression TK_EQ expression
			| expression TK_GE expression
			| expression TK_LE expression
			| expression TK_NE expression
			| expression TK_GT expression
			| expression TK_LT expression
			| expression TK_PLUS expression
			| expression TK_MULTI expression
			| expression TK_MINUS expression
			| expression KEYW_OR expression
			| expression KEYW_AND expression
			| expression KEYW_DIV expression
			| expression KEYW_MOD expression
			| KEYW_NOT expression %prec UNARY
			| TK_PLUS expression %prec UNARY
			| TK_MINUS expression %prec UNARY
			| function_call
			| TK_ID
			| expression TK_BRACKET_OPEN expression TK_BRACKET_CLOSE
			| TK_PAR_OPEN expression TK_PAR_CLOSE
			| TK_INT 
			| TK_CHAR
			| TK_STR
			| KEYW_TRUE
			| KEYW_FALSE

;

l_value:		  TK_ID
			| TK_ID TK_BRACKET_OPEN expression TK_BRACKET_CLOSE
;

function_call:		  TK_ID TK_PAR_OPEN argument_list TK_PAR_CLOSE
;

argument_list:		/*empty*/
			| expression
			| argument_list TK_COMMA expression
;

function_def:		  KEYW_FUNCTION TK_ID TK_PAR_OPEN parameter_list TK_PAR_CLOSE KEYW_IS function_body KEYW_END
			| KEYW_FUNCTION TK_ID TK_PAR_OPEN parameter_list TK_PAR_CLOSE TK_COL type_name KEYW_IS function_body KEYW_END

;

fdef:		          /*empty*/
			| variable_def fdef
			| function_def fdef
;




%%

main()
{

  int i;
 
  i=yyparse();
  printf("yyparse returned: %d\n",i);
  return i;
}
 
extern int linenum;
 
yyerror(char *s)
{
  printf("Syntax Error in line %d: %s\n",linenum,s);
}
 

