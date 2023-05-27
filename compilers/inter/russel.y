%{

#include <stdio.h>

#include "symbolc.h"
#include "inter.h"
#ifndef MAXFUNCALLNESTING
#define MAXFUNCALLNESTING 10
#endif

	extern FILE     *yyin, *yyout;
	extern int      linenum;
	extern char	*yytext;

	functionEntry   *func;
	functionEntry   *fcnts[MAXFUNCALLNESTING];
	int		fcallnesting=0;
	int             args = 0;
	int 		errornum=0;
	int		argerr;

	char	*msg;
	int     crerror(char *,int,char *);
	void 	predefined_functions();

%}

%union {
	int num;
	char *		str;
	char *		chr;
	char *          place;
	char		bool;
	struct {
		LIST             *true,*false,*next;
		VarTypes 	  type;
		char              place[30];
		int               num;
		symbolTableEntry *entry;
		functionEntry    *fcnt;
	} expr;

}

%token <place> TK_ID  
%token <num>   TK_INT
%token <chr>   TK_CHAR 
%token <str>   TK_STR 
%token <num>   TK_COMMA
%token TK_PLUS        
%token TK_MINUS      
%token TK_MULTI     
%token TK_ASSGN    
%token TK_LT      
%token TK_LE         
%token TK_EQ          
%token TK_NE           
%token TK_GT            
%token TK_GE             
%token TK_COL             
%token TK_THEN             
%token TK_ELSE              
%token TK_BRACKET_OPEN       
%token TK_BRACKET_CLOSE       
%token TK_PAR_OPEN 
%token TK_PAR_CLOSE 
%token KEYW_AND      
%token KEYW_BOOLEAN   
%token KEYW_CHAR       
%token KEYW_DIV         
%token KEYW_DO           
%token KEYW_END           
%token <num>   KEYW_FALSE  
%token <num>   KEYW_FUNCTION
%token KEYW_IF           
%token KEYW_INTEGER       
%token KEYW_IS             
%token KEYW_MOD             
%token KEYW_NOT              
%token KEYW_OR                
%token <num> 	KEYW_REF 
%token KEYW_RETURN      
%token KEYW_STRING     
%token <num>     KEYW_TRUE               
%token <expr>    KEYW_VAR               

%type  <expr>    type_name,function_body,variable_def,function_def, fdef, statement, id_list, condition_list, condition,
l_value, expression, function_call, arguments,argument_list,function_def_tmp
%type <num>   program ,  parameter_list, parameter,non_empty_par_list
%type <place> identifier


%right TK_BRACKET_OPEN
%left TK_EQ,TK_NE,TK_GT,TK_LT,TK_GE,TK_LE
%left TK_PLUS,TK_MINUS,KEYW_OR
%left TK_MULTI,KEYW_DIV,KEYW_MOD,KEYW_AND
%left UNARY

%%

program:    
		{ 
			OpenScope("main");
			predefined_functions(); 
		}
		function_body 

		{

			genquad("endu",GetCurrentScopeName(),"-","-");
			CloseScope();
		}

function_body:      
		fdef 
		{
			genquad("unit",GetCurrentScopeName(),"-","-");
		}
		statement
		;

identifier: 
		TK_ID {
			$$=(char *)malloc((size_t)30);
			strcpy($$,yytext);
		};

function_def:
		KEYW_FUNCTION identifier TK_PAR_OPEN 
		{
			if(Lookup($2,SEARCH_CURRENT_SCOPE))
				crerror("Duplicate function name",linenum,"");
			else{
				func=NewFunction($2,VoidRet);
				Insert(func);
				OpenScope($2);
			}
		}
		parameter_list TK_PAR_CLOSE 
		function_def_tmp
;
function_def_tmp:
		KEYW_IS function_body KEYW_END
		{
			genquad("endu",GetCurrentScopeName(),"-","-");
			CloseScope();
		}
		| 
		TK_COL 
		type_name {
			SetReturnType(func,$<expr>2.type);
		}
		KEYW_IS function_body KEYW_END
		{
			genquad("endu",GetCurrentScopeName(),"-","-");
			CloseScope();
		};


fdef:           {   /*empty*/
		
		}
		| variable_def fdef
		| function_def fdef
;

variable_def:       
		KEYW_VAR id_list
;

id_list:     
		identifier TK_COMMA 
		id_list {
			if(Lookup($1,SEARCH_CURRENT_SCOPE))
				crerror("Duplicate Variable Definition:",linenum,"");
			else {
				$$.type=$3.type;
				Insert(NewVariable($1,$3.type));
			}
		}
		| identifier TK_COL type_name
		{
			if(Lookup($1,SEARCH_CURRENT_SCOPE))
				crerror("Duplicate Variable Definition:",linenum,"");
			else {
				$$.type=$3.type;
				Insert(NewVariable($1,$3.type));
			}
		}
;


type_name:       
		KEYW_INTEGER {
			$$.type=IntegerType;
		}
		| KEYW_BOOLEAN       {
			$$.type=BooleanType;
		}
		| KEYW_CHAR          {
			$$.type=CharType;
		}
		| KEYW_STRING        {
			$$.type=StringType;
		}
;


parameter_list:      /* empty */
		{
		}
		| non_empty_par_list

;
non_empty_par_list:
		parameter
		| non_empty_par_list TK_COMMA parameter
;

parameter:       
		identifier TK_COL type_name 
		{
			parameterEntry * par;
			if(Lookup($1,SEARCH_CURRENT_SCOPE))
				crerror("parameter:Duplicate Variable Definition:",linenum,"");
			else {
				if (par=NewParameter($1,$3.type,ByValue,func))
					Insert(par);
				else crerror("Could not add parameter ",linenum,"");
			}
		}
		| identifier TK_COL KEYW_REF type_name {
			parameterEntry * par;
			if(Lookup($1,SEARCH_CURRENT_SCOPE))
				crerror("parameter:Duplicate Variable Definition:",linenum,"");
			else {
				if (par=NewParameter($1,$4.type,ByReference,func))
					Insert(par);
				else crerror("Could not add parameter ",linenum,"");
			}
		}
;


statement:     /* empty */
		{
		}
		| l_value TK_ASSGN expression { 
			char tn[10];
			if($1.type!=$3.type) crerror("Type mismatch",linenum,"");
			else 
				if($1.type==BooleanType) {
					backpatch($3.true,nextquad);
					genquad(":=","true","-",$1.place);
					sprintf(tn,"%d",nextquad+2);
					genquad("jump","-","-",tn);
					backpatch($3.false,nextquad);
					genquad(":=","false","-",$1.place);
				}
				else genquad(":=",$3.place,"-",$1.place);
			$$.next=NULL;
		}
		statement
		| KEYW_IF condition_list {
			backpatch($2.next,nextquad);
		}
		KEYW_END statement
		| KEYW_DO { 
			$<expr>$.num=nextquad;
		}
		condition_list {
			backpatch($<expr>3.next,$<expr>2.num);
		}
		KEYW_END statement
		| function_call {
			$$.type=$1.type;
			strcpy($$.place,$1.place);
			/*
					Result ignored if function call is statement.
			
					   if ($$.type==BooleanType) {
						 $$.true=makelist(nextquad);
						 genquad("ifb",$1.place,"-","?");
						 $$.false=makelist(nextquad);
						 genquad("jump","-","-","?");
			   }
			   else */ $$.true=$$.false=NULL;
		}
		statement
		| KEYW_RETURN {
			if (GetReturnType(Lookup(GetCurrentScopeName(),
			    SEARCH_ALL_SCOPES))==VoidRet)
				genquad("ret","-","-","-");
			else 
				crerror("Non-void function does not return a value",linenum,"");
			$$.next=NULL;
		}

		| KEYW_RETURN TK_PAR_OPEN expression TK_PAR_CLOSE {
			if (GetReturnType(Lookup(GetCurrentScopeName(),
			    SEARCH_ALL_SCOPES))==$3.type)
				if ($3.type==BooleanType) {
					backpatch($3.true,nextquad);
					genquad("retv","true","-","-");
					genquad("ret","-","-","-");
					backpatch($3.false,nextquad);
					genquad("retv","false","-","-");
			genquad("ret","-","-","-");
		}
		else {
			genquad("retv",$3.place,"-","-");
			genquad("ret","-","-","-");
		}
			else crerror("Type mismatch in return statement",linenum,"");
			$$.next=NULL;
		}
;


condition_list:   
		condition {
			$$.next=$1.next;
			/*new*/
			$$.true=NULL;
			$$.false=NULL;
		}
		| condition TK_ELSE condition_list {
			$$.next=merge($1.next,$3.next);
			/*new*/
			$$.true=NULL;
			$$.false=NULL;
		}
;



condition:      
		expression {
			if ($1.type!=BooleanType)
			  crerror("boolean expression required for conditional statement",linenum,"");
			else {
				backpatch($1.true,nextquad);
			}
		}
		TK_THEN statement {
			$$.next=makelist(nextquad);
			genquad("jump","-","-","?");
			backpatch($1.false,nextquad);
};


expression:
		expression TK_EQ {
			$<expr>$.num=nextquad;
		} 
		expression {
			if($1.type==StringType || $4.type==StringType)
				crerror("'=' operand not valid for strings",linenum,"");
				else
				if ($1.type!=$4.type) crerror("Type mismatch",linenum,"");
				else {
					$$.type=BooleanType;
					if ($1.type!=BooleanType) {
						$$.true=makelist(nextquad);
						$$.false=makelist(nextquad+1);
						genquad("=",$1.place,$4.place,"?");
						genquad("jump","-","-","?");
					}
					else {
						char tn[10];
						temporaryEntry *tmp=NewTemporary(BooleanType);
						char *tmpname=GetName(tmp);
						Insert(tmp);
						backpatch($1.true,nextquad);
						backpatch($1.false,nextquad+2);
						genquad(":=","true","-",tmpname);
						sprintf(tn,"%d",$<expr>3.num);
						genquad("jump","-","-",tn);
						genquad(":=","false","-",tmpname);
						genquad("jump","-","-",tn);
						backpatch($4.true,nextquad);
						backpatch($4.false,nextquad+2);
						$$.true=merge(makelist(nextquad),makelist(nextquad+3));
						$$.false=merge(makelist(nextquad+1),makelist(nextquad+2));
						genquad("ifb",tmpname,"-","?");
						genquad("jump","-","-","?");
						genquad("ifb",tmpname,"-","?");
						genquad("jump","-","-","?");
					}
				}
		}

		| expression TK_GE expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '>=' operand:Invalid Types",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad(">=",$1.place,$3.place,"?");
				genquad("jump","-","-","?");
			}
		}
		| expression TK_LE expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '<=' operand:Invalid Types",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad("<=",$1.place,$3.place,"?");
				genquad("jump","-","-","?");
			}
		}

		| expression TK_NE expression {
			if($1.type==StringType || $3.type==StringType)
				crerror("'<>' operand not valid for strings",linenum,"");
				else
				if ($1.type!=$3.type) crerror("Type mismatch",linenum,"");
				else {
					$$.type=BooleanType;
					if ($1.type!=BooleanType) {
						$$.true=makelist(nextquad);
						$$.false=makelist(nextquad+1);
						genquad("<>",$1.place,$3.place,"?");
						genquad("jump","-","-","?");
					}
					else {
						char tn[10];
						temporaryEntry *tmp=NewTemporary(BooleanType);
						char *tmpname=GetName(tmp);
						Insert(tmp);
						backpatch($1.true,nextquad);
						genquad(":=","true","-",tmpname);
						sprintf(tn,"%d",nextquad+2);
						genquad("jump","-","-",tn);
						backpatch($1.false,nextquad);
						genquad(":=","false","-",tmpname);
						$$.false=merge(makelist(nextquad),makelist(nextquad+3));
						$$.true=merge(makelist(nextquad+1),makelist(nextquad+2));
						backpatch($3.true,nextquad);
						genquad("ifb",tmpname,"-","?");
						genquad("jump","-","-","?");
						backpatch($3.false,nextquad);
						genquad("ifb",tmpname,"-","?");
						genquad("jump","-","-","?");
					}
				}
		}

		| expression TK_GT expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '>' operand:Invalid Type",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad(">",$1.place,$3.place,"?");
				genquad("jump","-","-","?");
			}
		}


		| expression TK_LT expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '<' operand:Invalid Types",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad("<",$1.place,$3.place,"?");
				genquad("jump","-","-","?");
			}
		}

		| expression TK_PLUS expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '+' operand:Invalid Types",linenum,"");
			else {
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("+",$1.place,$3.place,tmpname);
				strcpy($$.place,tmpname);
				$$.true=$$.false=NULL;
			}
		}

		| expression TK_MULTI expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '*' operand:Invalid Types",linenum,"");
			else {
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("*",$1.place,$3.place,tmpname);
				strcpy($$.place,tmpname);
				$$.true=$$.false=NULL;
			}
		}

		| expression TK_MINUS expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of '-' operand:Invalid Types",linenum,"");
			else {
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("-",$1.place,$3.place,tmpname);
				strcpy($$.place,tmpname);
				$$.true=$$.false=NULL;
			}
		}

		| expression KEYW_OR {
			backpatch($1.false,nextquad);
		}
		expression {
			if ($1.type!=BooleanType||$4.type!=BooleanType)
				crerror ("Wrong use of 'OR' operand:Invalid Type",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=merge($1.true,$<expr>4.true);
				$$.false=$<expr>4.false;
			}
		}


		| expression KEYW_AND {
			backpatch($1.true,nextquad);
		}
		expression {
			if ($1.type!=BooleanType||$4.type!=BooleanType)
				crerror ("Wrong use of 'OR' operand:Invalid Type",linenum,"");
			else {
				$$.type=BooleanType;
				$$.true=merge($1.false,$<expr>4.false);
				$$.true=$<expr>4.true;
			}
		}

		| expression KEYW_DIV expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of 'div' operand:Invalid Types",linenum,"");
			else {
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("/",$1.place,$3.place,tmpname);
				strcpy($$.place,tmpname);
				$$.true=$$.false=NULL;
			}
		}

		| expression KEYW_MOD expression {
			if ($1.type!=IntegerType||$3.type!=IntegerType)
				crerror ("Wrong use of 'mod' operand:Invalid Types",linenum,"");
			else {
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("%",$1.place,$3.place,tmpname);
				strcpy($$.place,tmpname);
				$$.true=$$.false=NULL;
			}
		}

		| KEYW_NOT expression %prec UNARY
		{
			if ($<expr>2.type!=BooleanType)
				crerror("Wrong use of 'not' operand:Invalid type",linenum,"");
				else
			{
				$$.true=$<expr>2.false;
				$$.false=$<expr>2.true;
				$$.type=BooleanType;
			}
		}
		| TK_PLUS expression %prec UNARY
		{
			if ($<expr>2.type!=IntegerType)
				crerror("Wrong use of '+' operand:Invalid type",linenum,"");
			else $$=$<expr>2;
		}

		| TK_MINUS expression %prec UNARY
		{
			if ($<expr>2.type!=IntegerType)
				crerror("Wrong use of '+' operand:Invalid type",linenum,"");
				else
			{
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("um",$<expr>2.place,"-",tmpname);
				strcpy($$.place,tmpname);
			}
		}

		| function_call {
			if ($1.type!=BooleanType) $$=$1;
			else {
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad("ifb",$1.place,"-","?");
				genquad("jump","-","-","?");
			}
		}


		| identifier {
			variableEntry *vE;
			if(!(vE=Lookup($1,SEARCH_ALL_SCOPES)))
				crerror("Expression:Undefined Variable",linenum,"");
			else {
				$$.type=GetType(vE);
				strcpy($$.place,$1);
				if ($$.type==BooleanType) {
					$$.true=makelist(nextquad);
					genquad("ifb",$1,"-","?");
					$$.false=makelist(nextquad);
					genquad("jump","-","-","?");
				}
			}
		}
		| expression TK_BRACKET_OPEN expression TK_BRACKET_CLOSE {
			if ($1.type!=StringType) {
				crerror("Wrong use of '[]' operands:string expected before []",linenum,"");
			}
			else if ($3.type != IntegerType)  {
				crerror("Wrong use of '[]' operands:integer expected inside []",linenum,"");
			}
			else {
				$$.type=CharType;
				sprintf($$.place,"%s[%s]",$1.place,$3.place);
			}
		}

		| TK_PAR_OPEN expression TK_PAR_CLOSE {
			$$=$<expr>2;
		}
		| TK_INT {
			$$.type=IntegerType;
			strcpy($$.place,yytext);
		}

		| TK_CHAR {
			$$.type=CharType;
			strcpy($$.place,yytext);
		}

		| TK_STR   {
			$$.type=StringType;
			strcpy($$.place,yytext);
		}

		| KEYW_TRUE {
			strcpy($$.place,"");
			$$.type=BooleanType;
			$$.true=makelist(nextquad);
			genquad("jump","-","-","?");
			$$.false=NULL;
		}

		| KEYW_FALSE {
			strcpy($$.place,"");
			$$.type=BooleanType;
			$$.false=makelist(nextquad);
			genquad("jump","-","-","?");
			$$.true=NULL;
		};



l_value:      
		identifier {
			variableEntry *vE;
			if(!(vE=Lookup($1,SEARCH_ALL_SCOPES)))
				crerror("l-value:Undefined Variable:",linenum,"");
			else {
				$$.type=GetType(vE);
				strcpy($$.place,$1);
			}
		}

		| identifier TK_BRACKET_OPEN expression TK_BRACKET_CLOSE {

			variableEntry *vE;
			if(!(vE=Lookup($1,SEARCH_ALL_SCOPES)))
				crerror("string l-value:Undefined Variable:",linenum,"");
			else {
				$$.type=GetType(vE);
				strcpy($$.place,$1);

				if ($$.type!=StringType) {
					crerror("Wrong use of '[]' operands:string expected before []",linenum,"");
				}
				else if ($3.type != IntegerType)  {
					crerror("Wrong use of '[]' operands:integer expected inside []",linenum,"");
				}
				else {
					$$.type=CharType;
					sprintf($$.place,"%s[%s]",$1,$3.place);
				}
			}
};



function_call:      
		identifier {
			if ((func=Lookup($1,SEARCH_ALL_SCOPES))==NULL)
				crerror("Undeclared function",linenum,"");
			else if (WhatIs(func)!=FunctionEnt)
				crerror("Call to non-function",linenum,"");
			else {
				$<expr>$.fcnt=func;
				fcallnesting++;
				fcnts[fcallnesting]=func;
			}
		}


		TK_PAR_OPEN argument_list  TK_PAR_CLOSE {
			fcallnesting--;
		}
		{
			temporaryEntry *tmp;
			char           *tmpname;
			if (GetTotalArguments($<expr>2.fcnt)!=$<expr>4.num) {
			    if (!argerr)
				crerror("Invalid Number of Arguments in Function call",linenum,"");
			    else argerr=0;
			}
			else {
				$$.type=GetReturnType($<expr>2.fcnt);
				if ($$.type!=VoidRet) {
					tmp=NewTemporary($$.type);
					Insert(tmp);
					genquad("par",(tmpname=GetName(tmp)),"RET","-");
					strcpy($$.place,tmpname);
				}
				else strcpy($$.place,"");
				genquad("call","-","-",$1);
			}
		};


argument_list:    /*empty*/
		{
			$$.num=0;
		}
		| {
			args=1;
		} 
		arguments {
			$<expr>$.num=$<expr>2.num;
		};


		arguments:    
		expression {
			func=fcnts[fcallnesting];
			if (GetTotalArguments(func)<args) {
			    msg=strdup(GetName(func));
			    crerror("Too many arguments in function call:",linenum,msg);
			    free(msg);
			    argerr=1;
			}
			else if ($1.type!=GetType(GetArgument(func,args)))
				crerror("Invalid Parameter Type",linenum,"");
			else {
				char  valref[3];
				if (GetMode(GetArgument(func,args)) == ByValue) strcpy(valref,"V");
				else strcpy(valref,"V");
				if ($1.type==BooleanType) {
					char tn[10];
					backpatch($1.true,nextquad);
					genquad("par","true",valref,"-");
					sprintf(tn,"%d",nextquad+2);
					genquad("jump","-","-",tn);
					backpatch($1.false,nextquad);
					genquad("par","false",valref,"-");
				}
				else {
					genquad("par",$1.place,valref,"-");
				}
			} 
			$$.num=args;
		}
		|  expression 
		    {
			func=fcnts[fcallnesting];
			if (GetTotalArguments(func)<args) {
			    msg=strdup(GetName(func));
			    crerror("Too many arguments in function call:",linenum,msg);
			    free(msg);
			    argerr=1;
			}
			else if ($1.type!=GetType(GetArgument(func,args)))
				crerror("Invalid Parameter Type",linenum,"");
			else {
				char  valref[3];
				if (GetMode(GetArgument(func,args)) == ByValue) strcpy(valref,"V");
				else strcpy(valref,"R");
				if ($1.type==BooleanType) {
					char tn[10];
					backpatch($1.true,nextquad);
					genquad("par","true",valref,"-");
					sprintf(tn,"%d",nextquad+2);
					genquad("jump","-","-",tn);
					backpatch($1.false,nextquad);
					genquad("par","false",valref,"-");
				}
				else {
					genquad("par",$1.place,valref,"-");
				}
			}
		}
		TK_COMMA {
			++args;
		} 
		arguments
		{
			$$.num=args;
		};

%%


void predefined_functions()
{
	Insert((func=NewFunction("printi",VoidRet)));
	OpenScope("printi");
	Insert((NewParameter("i",IntegerType,ByValue,func)));
	CloseScope();

	Insert((func=NewFunction("printb",VoidRet)));
	OpenScope("printb");
	Insert(NewParameter("b",BooleanType,ByValue,func));
	CloseScope();

	Insert((func=NewFunction("printc",VoidRet)));
	OpenScope("printc");
	Insert(NewParameter("c",CharType,ByValue,func));
	CloseScope();

	Insert((func=NewFunction("prints",VoidRet)));
	OpenScope("prints");
	Insert(NewParameter("s",StringType,ByValue,func));
	CloseScope();
	Insert(NewFunction("readi",IntegerRet));
	Insert(NewFunction("readb",BooleanRet));
	Insert(NewFunction("readc",CharRet));
	Insert(NewFunction("reads",StringRet));
}

yyerror(char *s)
{
	printf("Syntax Error in line %d: %s\n",linenum,s);
	errornum=-1;
}
crerror(char *s,int ln,char *s1)
{
	printf("line %d:%s %s\n",ln,s,s1);
	errornum++;

}

int main(int argc, char *argv[]) {

	if (argc > 1) {
		if ((yyin = fopen(argv[1], "r")) == NULL) {
			fprintf(stderr, "Cannot open file %s\n", argv[1]);
		}
	}
	if (argc > 2) {
		if ((yyout = fopen(argv[2], "w")) == NULL) {
			fprintf(stderr, "Cannot open file %s\n", argv[2]);
		}
	}

	InitSymbolTable();

	if (yyparse()==0 && !errornum) printf("\nCODE ACCEPTED\n");
	else  if (errornum>0 )printf("\n%d error(s) found\n", errornum);

	if (!errornum) {
		printf("\n");
		printicode();
		printf("\n");
	}
	else printf("rcomp failed \n");
	DestroySymbolTable();
	discardicode();

	fclose(yyin);
	fclose(yyout);
	return 0;
}
