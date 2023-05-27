%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "symbolc.h"
#include "inter.h"

#ifndef MAXFUNCALLNESTING
#define MAXFUNCALLNESTING 10
#endif

#define MAXSTRINGS 1024
#define EXTFUNCS 8

	extern FILE     *yyin, *yyout;
	extern int       linenum;
	extern char	*yytext;

	functionEntry   *func;
	functionEntry   *fcnts[MAXFUNCALLNESTING];
	int              fargs[MAXFUNCALLNESTING];
	int		 fcallnesting=0;
	int              args = 0;
	int 		 errornum=0;
	int		 argerr;
	int		 asmquad=1;
	int		 outasm=1;
	char 		 tmpstr[200];
	char		 st2as[20];
	char		 *strings[MAXSTRINGS];
	char		 *freeme;
	int		 stringnum=0;
	int 		 extfuncf[EXTFUNCS];
	char 		*extfuncn[EXTFUNCS]={"printi","printb","printc","prints","readi","readb","readc","reads"};

	char		*msg;
	FILE 		*fout;
	int     	 crerror(char *,int,char *);
	void 		 predefined_functions();
	void 		 asmfinish();
	void 		 asmstart(char *s);
	void		 genasm();
	void loadAddr(const char *, char *);

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
			OpenScope("_main");
			func=NewFunction("_main",VoidRet);
			Insert(func);
			predefined_functions(); 
			if (outasm)
			   asmstart("_main");
		}
		function_body 

		{

			genquad("endu",GetCurrentScopeName(),"-","-");
			if (outasm)
			    genasm();
			asmfinish();
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
			if (outasm)
			    genasm();
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
			if (outasm)
			    genasm();
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
			if($1.type!=$3.type) crerror("Type mismatch in `:='",linenum,"");
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
			   else 
			*/ 
			$$.true=$$.false=NULL;
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
				if ($1.type!=$4.type) crerror("Type mismatch in `='",linenum,"");
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '>=' operand",linenum,"");
			else if ($1.type!=IntegerType && $1.type!=CharType)
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '<=' operand",linenum,"");
			else if ($1.type!=IntegerType && $1.type!=CharType)
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
				if ($1.type!=$3.type) crerror("Type mismatch in `<>'",linenum,"");
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '>' operand",linenum,"");
			else if ($1.type!=IntegerType && $1.type!=CharType)
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '<' operand",linenum,"");
			else if ($1.type!=IntegerType && $1.type!=CharType)
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '+' operand",linenum,"");
			else if ($1.type!=IntegerType )
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
			if ($1.type!=$3.type)
			    crerror ("Type mismatch: '*' operand",linenum,"");
			else if ($1.type!=IntegerType )
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
			
			if (!strcmp($1.place,"true")&&!strcmp($4.place,"false"))
			    backpatch($4.false,nextquad+2); /*Added 10-6*/
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
				/*
				temporaryEntry *tmp;
				char *tmpname;
				tmp=NewTemporary(IntegerType);
				tmpname=GetName(tmp);
				$$.type=IntegerType;
				Insert(tmp);
				genquad("um",$<expr>2.place,"-",tmpname);
				strcpy($$.place,tmpname);
				*/
				genquad("um",$<expr>2.place,"-",$<expr>2.place);
				strcpy($$.place,$2.place);
			}
		}

		| function_call {
			if ($1.type!=BooleanType) $$=$1;
			else {
				$$.true=makelist(nextquad);
				$$.false=makelist(nextquad+1);
				genquad("ifb",$1.place,"-","??");
				genquad("jump","-","-","??");
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
					genquad("ifb",$1,"-","???");
					$$.false=makelist(nextquad);
					genquad("jump","-","-","???");
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
			strcpy($$.place,"true");
			$$.type=BooleanType;
			$$.true=makelist(nextquad);
			genquad("jump","-","-","?");
			$$.false=NULL;
		}

		| KEYW_FALSE {
			strcpy($$.place,"false");
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


		TK_PAR_OPEN argument_list  TK_PAR_CLOSE 
		{
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
			fargs[fcallnesting]=0;
		}
		| {
			args=1;
			fargs[fcallnesting]=1;
		} 
		arguments {
			$<expr>$.num=$<expr>2.num;
		};


arguments:    
		expression {
			func=fcnts[fcallnesting];
			args=fargs[fcallnesting];
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
				if ($1.type==BooleanType&&!strcmp(valref,"V")) {
					char tn[10];
					backpatch($1.true,nextquad);
					genquad("par","true",valref,"-");
					sprintf(tn,"%d",nextquad+2);
					genquad("jump","-","-",tn);
					backpatch($1.false,nextquad);
					genquad("par","false",valref,"-");
				}
				else {
					if ($1.type==BooleanType) {
					    backpatch($1.true,nextquad);
					    backpatch($1.false,nextquad);
					}
					genquad("par",$1.place,valref,"-");
				}
			} 
			$$.num=args;
		}
		|  expression 
		    {
			func=fcnts[fcallnesting];
			args=fargs[fcallnesting];
			if (GetTotalArguments(func)<args) {
			    msg=strdup(GetName(func));
			    crerror("Too many Arguments in function call:",linenum,msg);
			    free(msg);
			    argerr=1;
			}
			else if ($1.type!=GetType(GetArgument(func,args)))
				crerror("Invalid Parameter Type",linenum,"");
			else {
				char  valref[3];
				if (GetMode(GetArgument(func,args)) == ByValue) strcpy(valref,"V");
				else strcpy(valref,"R");
				if ($1.type==BooleanType&&!strcmp(valref,"V")) {
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
			fargs[fcallnesting]++;
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



/*Return a valid masm function name, from a russel function name*/
char *asmfuncname(char *funcname, char *res)
{
  int i;
  symbolTableEntry *lookupres;

  lookupres=Lookup(funcname,SEARCH_ALL_SCOPES);
  i=GetEntryNestingLevel(lookupres);
/*  fprintf(stderr,"DEBUG: asmfuncname: %s nesting level is %d\n",funcname,i);*/
  if (i==1) {
    for(i=0; i<EXTFUNCS; i++)
      if (strcmp(funcname,extfuncn[i])==0) {
        extfuncf[i]=TRUE;
        sprintf(res,"_%s",funcname);
        return res;
      }
/*    fprintf(stderr,"asmfuncname: Not a standard routine\n");*/
  }
  sprintf(res,"_%s_%d",funcname,GetFunctionNumber((functionEntry *)lookupres));
  return(res);
}

int isBool(const char *a, int *intval)
{
  if (strcmp(a,"true")==0) {
    *intval=TRUE;
    return TRUE;
  }
  if (strcmp(a,"false")==0) {
    *intval=FALSE;
    return TRUE;
  }
  return 0;
}

isIntC(char *c)
{
  return (isdigit(*c) || *c=='-');
}

isCharC(char *c)
{
  return (*c=='\'');
}

isStrC(char *c)
{
  return (*c=='\"');
}

isIstr(char *c) /*Is indexed string?*/
{
  return (strchr(c,'[')?1:0);
}

char * strname(char *c)
{
 int i=0;
 char *s;

 s=malloc(strlen(c));
 while(*c!='[') s[i++]=*(c++);
 s[i]=(char)0;
 return strdup(s);
}

char *strpos(char *c)
{
 int i=0;
 char *s;

 s=malloc(strlen(c));
 while (*c!='[') c++;c++;
 while (*c!=']') s[i++]=*(c++);
 s[i]=(char)0;
 return strdup(s);
}

char *str2asc(char *c)
{ char s[20];
  int i;

  bzero(s,sizeof(s));
  for (i=0;*c;i++) {
    if (*c=='\\') {
       switch(*(++c)) {
         case '0' :
	          s[i]='\0';break;
	 case 'n' :
	          s[i]='\n';break;
	 case 't' :
	          s[i]='\t';break;
	 case '\'':
	          s[i]='\'';break;
	 case '\"':
	          s[i]='\"';break;
	 case '\\':
	          s[i]='\\';break;
	 default:
	 	  s[i]=*c;break;
       }
       c++;
    } /*if c='\'*/
    else 
      s[i]=(*c++);
  } /*for*/
  s[i-1]=(char)0;  /*Get rid of " " quotes*/
  bzero(st2as,sizeof(st2as));
  memcpy(st2as,&s[1],sizeof(s)-1);
  return  st2as;
}

char *cc2asc(char *c) /*CharConstant2ASCii*/
{
  char s[10];
  if (c[1]=='\\')  {
	switch (c[2]) {
	case '0' : strcpy(s,"00h");break;
	case 'n' : strcpy(s,"0Ah");break;
	case 't' : strcpy(s,"09h");break;
	case '\'' : strcpy(s,"27h");break;
	case '\"' : strcpy(s,"22h");break;
	case '\\' : strcpy(s,"5Ch");break;
	}
  }
  else
    sprintf(s,"%Xh",(int)c[1]);
  return strdup(s);
}

char *newstring(char *str)
{
  char s[17];
  char *ss;
  int i;

  for(i=0;i<stringnum;i++)
    if(!strcmp(str,strings[i])) {
      sprintf(s,"@STRING_%d",i);
      return strdup(s);
    }
  if(stringnum<MAXSTRINGS) {
	ss=str2asc(str);
	strings[stringnum]=(char *) malloc(sizeof(str2asc(str)));
  	memcpy(strings[stringnum],ss,sizeof(str2asc(str)));
	sprintf(s,"@STRING_%d",stringnum);
	stringnum++;
	return strdup(s);
  }
  else {
    fprintf(stderr,"Maximum #string limit reached:%d\n",MAXSTRINGS);
    exit(-1);
  }
}

void printstrings()
{
  int i;
  int j;

  for (i=0;i<stringnum;i++) {
    fprintf(fout,"\n@STRING_%d \tDB\t",i);j=0;
    while (strings[i][j])
      fprintf(fout,"%Xh, ",strings[i][j++]);
    fprintf(fout,"0h\n");
    free(strings[i]);
  }
}

void getAR(char *a)
{
  symbolTableEntry *lookupres;
  int ncur,na,i;

  /*lookupres=Lookup(a,SEARCH_ALL_SCOPES);*/
  ncur=GetScopeNestingLevel(GetCurrentScope());
  na=GetNestingLevelOf(a);
  fprintf(fout,"\tmov\tsi, word ptr [bp+4]\n");
  for (i=1; i<ncur-na; i++)
    fprintf(fout,"\tmov\tsi, word ptr [si+4]\n");
}

void load(const char *reg, char *a)
{
  int intval,type;
  symbolTableEntry *lookupres;
  variableEntry *var=Lookup(a,SEARCH_ALL_SCOPES);

  if (!var) {
    if (isIstr(a)) {
      char *str,*pos;

      str=strname(a);
      pos=strpos(a);

      if (!isStrC(str)) {
        loadAddr("si",str);
	load("di",pos);
	fprintf(fout,"\tadd\tsi, di\n");
	fprintf(fout,"\tmov\t%s, byte ptr [si]\n",reg);
      }
      else {
        if (isIntC(pos)) {
	  char *s,ch;
	  int index;

	  s=str2asc(str);
	  index=atoi(pos);
	  ch=s[index];
	  fprintf(fout,"\tmov\tal, %Xh\n",ch);
	  if (s) free(s);
	  }
	else {
	  char *s=newstring(str);

	  fprintf(fout,"\tlea\tsi, %s\n",s);
	  load("di",pos);
	  fprintf(fout,"\tadd\tsi, di\n");
	  fprintf(fout,"\tmov\t%s, byte ptr [si]\n",reg);
	  if (s) free(s);
	}
      } /*isStrC(str)*/
      if (str) free(str);if(pos) free(pos);
    } /*Is indexed string lala[5] or "asdf"[5]*/
    else if (isCharC(a)) {
      fprintf(fout,"\tmov\t%s, %s\n",reg,(freeme=cc2asc(a)));
      free(freeme);
    }
    else if (isIntC(a)) 
      fprintf(fout,"\tmov\t%s, %s\n",reg,a);
    else if (isBool(a,&intval)) 
      fprintf(fout,"\tmov\t%s, %d\n",reg,intval);
    else 
      fprintf(yyout,"Internal error #234-432, contact Microsoft\n");
  }
  else if (Lookup(a,SEARCH_CURRENT_SCOPE)) {
     type=GetType(var);

    if (WhatIs(var)==ParameterEnt && GetMode(var)==ByReference) {
      /*Paramater by reference*/
      fprintf(fout,"\tmov\tsi, word ptr [bp%+d]\n",GetOffset(var));
      if (type==CharType || type == BooleanType) 
        fprintf(fout,"\tmov\t%s, byte ptr [si]\n",reg);
      else
        fprintf(fout,"\tmov\t%s, word ptr [si]\n",reg);
    }
    else {
      /*Variable, or temp. variable, or parameter byvalue*/
      if (type==CharType || type == BooleanType) 
        fprintf(fout,"\tmov\t%s, byte ptr [bp%+d]\n",reg,GetOffset(var));
      else
        fprintf(fout,"\tmov\t%s, word ptr [bp%+d]\n",reg,GetOffset(var));
    }
  } /*Local entity*/
  else {
    /*not-local*/
    if (WhatIs(var)==ParameterEnt && GetMode(var)==ByReference) {
      /*Paramater by reference*/
      getAR(a);
      fprintf(fout,"\tmov\tsi, word ptr [si%+d]\n",GetOffset(var));
      if (type==CharType || type == BooleanType) 
        fprintf(fout,"\tmov\t%s, byte ptr [si]\n",reg);
      else
        fprintf(fout,"\tmov\t%s, word ptr [si]\n",reg);
    }
    else {
      /*Variable, or temp. variable, or parameter byvalue*/
      getAR(a);
      if (type==CharType || type == BooleanType) 
        fprintf(fout,"\tmov\t%s, byte ptr [si%+d]\n",reg,GetOffset(var));
      else
        fprintf(fout,"\tmov\t%s, word ptr [si%+d]\n",reg,GetOffset(var));
    }
  }
}


void loadAddr(const char *reg, char *a) {
    variableEntry   *var = Lookup(a, SEARCH_ALL_SCOPES);
    if (var==NULL) {
	if (isIstr(a)) {
	  char    *str, *pos;

	  str = strname(a);
	  pos = strpos(a);

	  if (!isStrC(str)) {
		  loadAddr(reg, str);
		  load("di", pos);
		  fprintf(fout, "\tadd\t %s, di\n", reg);
	  } else 
	    fprintf(yyout,"Internal compiler error 999-999:Typesetter busy.\n");
	  
	  if (str) free(str);
	  if (pos) free(pos);
	} else 
	fprintf(yyout, "%s:Internal compiler error 313-131:Fatal cache error - Cache is disabled\n",a);
    } 
    else
      if (GetEntryNestingLevel(var)==GetScopeNestingLevel(GetCurrentScope())+1){
	/* local-entity.*/
	if ((WhatIs(var)==ParameterEnt) && (GetMode(var)==ByReference)) {
	  /* parameter by reference.*/
	  fprintf(fout, "\tmov\t%s, word ptr [bp%+d]\n",reg,GetOffset(var));
	} 
	else {
	  /* temp variable or variable or parameter byValue*/
	  int   type = GetType(var);
	  /* Symbol Table types:
	  Integer:0
	  Character:1
	  Boolean:2
	  String:3
	  */
	  if (type==CharType || type==BooleanType ) /*Changed*/
	    fprintf(fout, "\tlea\t%s, byte ptr [bp%+d]\n",reg,GetOffset(var));
	  else 
	    fprintf(fout,"\tlea\t%s, word ptr [bp%+d]\n",reg,GetOffset(var));
	}
      } 
      else {
	/* non-local entity.*/
	if ((WhatIs(var)==ParameterEnt) && (GetMode(var)==ByReference)) {
	  /* param by reference.*/
	  getAR(a);
	  fprintf(fout, "\tmov\t%s, word ptr [si%+d]\n",reg,GetOffset(var));
	} 
	else {
	  /* var or temp var or parameter byValue*/
	  int     type = GetType(var);

	  getAR(a);
	  if (type==CharType || type==BooleanType) 
	    fprintf(fout,"\tlea\t%s, byte ptr [si%+d]\n",reg,GetOffset(var));
	   else 
	    fprintf(fout,"\tlea\t%s, word ptr [si%+d]\n",reg,GetOffset(var));
	} /*BuValue*/
      } /*non-local*/
}

void store(const char *reg, char *a) {
    variableEntry   *var = Lookup(a, SEARCH_ALL_SCOPES);
    int             type;

    if (var==NULL) {
	if (isIstr(a)) {
	    /* It'an Indexed string*/ 
	    char    *str, *pos;

	    str = strname(a);
	    pos = strpos(a);
	    loadAddr("si", str);
	    load("di", pos);
	    fprintf(fout, "\tadd\tsi, di\n");
	    fprintf(fout, "\tmov\tbyte ptr [si], %s\n", reg);
	    if (str) free(str);
	    if (pos) free(pos);
	    } 
	    else 
	      fprintf(yyout,"Internal error 789-987:i/o error mapping pages\n");
	    
    } 
    else
      if (GetEntryNestingLevel(var)==GetScopeNestingLevel(GetCurrentScope())+1){
      /*local-entity.*/
	if ((WhatIs(var)==ParameterEnt) && (GetMode(var)==ByReference)) {
	    /* param-by reference.*/
	    type = GetType(var);
	    fprintf(fout, "\tmov\tsi, word ptr [bp%+d]\n", GetOffset(var));
	    if (type==CharType || type==BooleanType) 
	      fprintf(fout, "\tmov\tbyte ptr [si], %s\n", reg);
	    else 
	      fprintf(fout, "\tmov\tword ptr [si], %s\n", reg);
	    
	} 
	else {
	  /* temporary var or var or parameter byValue */
	  type = GetType(var);
	  if (type==CharType || type==BooleanType) 
	    fprintf(fout,"\tmov\tbyte ptr [bp%+d], %s\n",GetOffset(var),reg);
	  else 
	    fprintf(fout,"\tmov\tword ptr [bp%+d], %s\n",GetOffset(var),reg);

	}	 
    } 
    else {
      /*Mh-topikh ontoths by Ref*/
      if (WhatIs(var)==ParameterEnt && GetMode(var)==ByReference) {
	getAR(a);
	fprintf(fout,"\tmov\tsi, word ptr [si%+d]\n",GetOffset(var));
	if (type==CharType || type==BooleanType) 
	  fprintf(fout,"\tmov\tbyte ptr [si], %s\n",reg);
	else 
	  fprintf(fout,"\tmov\tword ptr [si], %s\n",reg);
	
      } 
      else {
	/*By Value*/
	getAR(a);
	if (type==CharType || type==BooleanType) 
	  fprintf(fout,"\t\tmov byte ptr [si%+d], %s\n",GetOffset(var),reg);
	else 
	  fprintf(fout,"\t\tmov word ptr [si%+d], %s\n",GetOffset(var),reg);
		  
	    }
    }
}

void updateAL(QUAD q)
{
  int np,nx,qu,i,isext;

  np=GetScopeNestingLevel(GetCurrentScope());
  nx=GetNestingLevelOf(q.d);
  qu=np-nx-1;
/*  fprintf(fout,"DEBUG: updateAL: np: %d nx: %d\n",np,nx);*/

    isext=0;
    for(i=0; i<EXTFUNCS; i++)
      if (strcmp(q.d,extfuncn[i])==0) isext=1;

/*  if (np<nx || isext)*/
  if (np<nx)
    fprintf(fout,"\tpush\tbp\n");
  else if (np==nx)
    fprintf(fout,"\tpush\tword ptr [bp+4]\n");
  else {
    fprintf(fout,"\tmov\tsi, word ptr [bp+4]\n");
    for (;qu;qu--)
      fprintf(fout,"\tmov\tsi, word ptr [si+4]\n");
    fprintf(fout,"\tpush\tword ptr [si+4]\n");
  }
}

void asmstart(char *s)
{
  int i;

  for (i=0; i<EXTFUNCS; i++)
    extfuncf[i]=FALSE;
  fprintf(fout,"xseg\tsegment\tpublic\t'code'\n");
  fprintf(fout,"\tassume\tcs:xseg, ds:xseg, ss:xseg\n");
  fprintf(fout,"\torg\t100h\n");
  fprintf(fout,"\n");
  fprintf(fout,"main\tproc\tnear\n");
  /*fprintf(fout,"\tcall\tnear ptr _%s_1\n",s);*/
  fprintf(fout,"\tcall\tnear ptr %s\n",asmfuncname(s,tmpstr));
  fprintf(fout,"\tmov\tax, 4c00h\n");
  fprintf(fout,"\tint\t21h\n");
  fprintf(fout,"main\tendp\n");
  fprintf(fout,"\n");
}

void asmfinish()
{
  int i;

  for (i=0; i<EXTFUNCS; i++)
    if (extfuncf[i])
      fprintf(fout,"\n\textrn\t_%s : proc",extfuncn[i]);
  printstrings();
  fprintf(fout,"\n");
  fprintf(fout,"\n");
  fprintf(fout,"xseg\tends\n");
  fprintf(fout,"\tend\tmain\n");
  fprintf(fout,"\n");
}

char *label(int l)
{
  static char tmps[20];

  sprintf(tmps,"@%d",l);
  return tmps;
}


void quad2asm(QUAD q)
{ char curunit[256];
  symbolTableEntry *entry;
  if (errornum) return ;
    /*printf("\n%2d:  %s,%s,%s,%s\n",q.no,q.a,q.b,q.c,q.d);*/
    fprintf(fout,"\n%s:\n",label(q.no));
  if (strcmp(q.a,"unit")==0) {
    strcpy(curunit,asmfuncname(q.b,tmpstr));
    fprintf(fout,"%s\tproc\tnear\n",curunit);
    fprintf(fout,"\tpush\tbp\n");
    fprintf(fout,"\tmov\tbp, sp\n");
    fprintf(fout,"\tsub\tsp, %d\n",-GetNegOffset(GetCurrentScope(),0));
  } else if (strcmp(q.a,"+")==0) {
    load("ax",q.b);
    load("dx",q.c);
    fprintf(fout,"\tadd\tax, dx\n");
    store("ax",q.d);
  } else if (strcmp(q.a,"-")==0) {
    load("ax",q.b);
    load("dx",q.c);
    fprintf(fout,"\tsub\tax, dx\n");
    store("ax",q.d);
  } else if (strcmp(q.a,"*")==0) {
    load("ax",q.b);
    load("cx",q.c);
    fprintf(fout,"\timul\tcx\n");
    store("ax",q.d);
  } else if (strcmp(q.a,"/")==0) {
    load("ax",q.b);
    fprintf(fout,"\txor\tdx, dx\n");
    load("cx",q.c);
    fprintf(fout,"\tidiv\tcx\n");
    store("ax",q.d);
  } else if (strcmp(q.a,"mod")==0) {
    load("ax",q.b);
    fprintf(fout,"\txor\tdx, dx\n");
    load("cx",q.c);
    fprintf(fout,"\tidiv\tcx\n");
    store("dx",q.d);
  } else if (strcmp(q.a,"um")==0) {
    load("ax",q.b);
    fprintf(fout,"\tneg\tax\n");
    store("ax",q.d);
  } 
  else if (strcmp(q.a,":=")==0) {
    int type;
    
    if (entry=Lookup(q.d,SEARCH_ALL_SCOPES))
      type=GetType(entry);

    if ((!entry)||type==BooleanType||type==CharType) {
      load("al",q.b);
      store("al",q.d);
    }
    else if (type==IntegerType) {
      load("ax",q.b);
      store("ax",q.d);
    }
    else if (Lookup(q.b,SEARCH_ALL_SCOPES)) {
	/*We have a string, cannot load a string to ax!*/
        /*It's a string variable move [di]<-[si]*/
	/*Mallon ginetai kai me thn MOVSB*/
	int off;
	loadAddr("si",q.b);
	loadAddr("di",q.d);
	for (off=14;off>=0;off-=2) {
	  fprintf(fout,"\tmov\tax, word ptr [si%+d]\n",off);
	  fprintf(fout,"\tmov\tword ptr [di%+d], ax\n",off);
	}
      }
      else {
        /*It's a String Constant*/
	/*move [di]<-(string's bytes in hex) */
	int off;
	char strtmp[20];

	bzero(strtmp,sizeof(strtmp));
	memcpy(strtmp,str2asc(q.b),sizeof(strtmp));
	loadAddr("di",q.d);
	for (off=14;off>=0;off-=2) {
	  fprintf(fout,"\tmov\tax, %04Xh\n",(((int)strtmp[off+1])<<8)+strtmp[off]);
	  fprintf(fout,"\tmov\tword ptr [di%+d], ax\n",off);
	}
      }
  }
  else if (strcmp(q.a,"=")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else
        if (isCharC(q.b))
          type=CharType;
        else if (isIntC(q.b))
          type=IntegerType;
        else 
          type=BooleanType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tje\t%s\n",label(atoi(q.d)));
    }
    else if (type==CharType||type==BooleanType) {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dx\n");
      fprintf(fout,"\tje\t%s\n",label(atoi(q.d)));
    }

  }
  else if (strcmp(q.a,"<>")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else 
        if (isCharC(q.b))
	  type=CharType;
	else if (isIntC(q.b))
	  type=IntegerType;
	else 
	  type=BooleanType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tjne\t%s\n",label(atoi(q.d)));
    }
    else if (type==CharType||type==BooleanType) {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dx\n");
      fprintf(fout,"\tjne\t%s\n",label(atoi(q.d)));
    }

  } 
  else if (strcmp(q.a,">")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else
        if (isCharC(q.b))
          type=CharType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tjg\t%s\n",label(atoi(q.d)));
    }
    else {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dl\n");
      fprintf(fout,"\tjg\t%s\n",label(atoi(q.d)));
    }

  }
  else if (strcmp(q.a,"<")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else
        if (isCharC(q.b))
          type=CharType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tjl\t%s\n",label(atoi(q.d)));
    }
    else {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dl\n");
      fprintf(fout,"\tjl\t%s\n",label(atoi(q.d)));
    }

  }
  else if (strcmp(q.a,">=")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else
        if (isCharC(q.b))
          type=CharType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tjge\t%s\n",label(atoi(q.d)));
    }
    else {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dl\n");
      fprintf(fout,"\tjge\t%s\n",label(atoi(q.d)));
    }
  }
  else if (strcmp(q.a,"<=")==0) {
    int type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    else {
      if (entry=Lookup(q.c,SEARCH_ALL_SCOPES))
        type=GetType(entry);
      else
        if (isCharC(q.b))
          type=CharType;
    }
    if (type==IntegerType) {
      load("ax",q.b);
      load("dx",q.c);
      fprintf(fout,"\tcmp\tax, dx\n");
      fprintf(fout,"\tjle\t%s\n",label(atoi(q.d)));
    }
    else {
      load("al",q.b);
      load("dl",q.c);
      fprintf(fout,"\tcmp\tal, dl\n");
      fprintf(fout,"\tjle\t%s\n",label(atoi(q.d)));
    }
  } 
  else if (strcmp(q.a,"ifb")==0) {
    load("al",q.b);
    fprintf(fout,"\tor\tal, al\n");
    fprintf(fout,"\tjnz\t%s\n",label(atoi(q.d)));

  } 
  else if (strcmp(q.a,"par")==0) {
    char *str,*pos;
    int intval,type;
    if (entry=Lookup(q.b,SEARCH_ALL_SCOPES))
      type=GetType(entry);
    if (strcmp(q.c,"V")==0) {
      /*By Value*/
      if (!entry) {
        if (isIstr(q.b)) {
	  char *pos,*str;

	  str=strname(q.b);
	  pos=strpos(q.b);

	  if (isStrC(str)) {
	    if (isIntC(pos))
	      fprintf(fout,"\tmov\tal, %Xh\n",str2asc(str)[atoi(pos)]);
	    else {
	      fprintf(fout,"\tlea\tsi, %s\n",(freeme=newstring(str)));
	      free(freeme);
	      load("di",pos);
	      fprintf(fout,"\tadd\tsi, di\n");
	      fprintf(fout,"\tmov\tal, byte ptr [si]\n");
	    }
	  }
	  else { /*Not String constant*/
	    loadAddr("si",str);
	    load("di",pos);
	    fprintf(fout,"\tadd\tsi, di\n");
	    fprintf(fout,"\tmov\tal, byte ptr [si]\n");
	  }
	  if (str) free(str);if(pos) free(pos);
	  fprintf(fout,"\tsub\tsp, 1\n");
	  fprintf(fout,"\tmov\tsi, sp\n");
	  fprintf(fout,"\tmov\tbyte ptr [si], al\n"); /*push al only*/
      } /*end of if is indexed string*/
      else 
        if (isIntC(q.b)) {
	  fprintf(fout,"\tmov\tax, %s\n",q.b);
	  fprintf(fout,"\tpush\tax\n");
	}
      else
        if (isCharC(q.b)) {
	  fprintf(fout,"\tmov\tal, %s\n",(freeme=cc2asc(q.b)));
	  free(freeme);
	  fprintf(fout,"\tsub\tsp,1\n");
	  fprintf(fout,"\tmov\tsi, sp\n");
	  fprintf(fout,"\tmov\tbyte ptr [si],al\n"); /*Push al to stack*/
	}
      else
        if (isBool(q.b,&intval)) {
	  fprintf(fout,"\tsub\tsp, 1\n");
	  fprintf(fout,"\tmov\tsi, sp\n");
	  fprintf(fout,"\tmov\tbyte ptr [si], %d\n",intval);
	}
      else
        if (isStrC(q.b)) {
	  int off;
	  char strtmp[20];
	    
	  bzero(strtmp,sizeof(strtmp));
	  memcpy(strtmp,str2asc(q.b),16);
	    
	  for (off=14;off>=0;off-=2) {
	    fprintf(fout,"\tmov\tax, %04Xh\n",(((int)strtmp[off+1])<<8)+strtmp[off]);
	    fprintf(fout,"\tpush\tax\n");
	  }
	}
	else fprintf(yyout,"Internal error 284-482:panic: /vmunix??? parity error in uda0\n");

      } /*if !entry*/
      else if (type==IntegerType) {
	load("ax",q.b);
	fprintf(fout,"\tpush\tax\n");
      }
      else if (type==CharType||type==BooleanType) {
	load("al",q.b);
	fprintf(fout,"\tsub\tsp, 1\n");
	fprintf(fout,"\tmov\tsi, sp\n");
	fprintf(fout,"\tmov\tbyte ptr [si], al\n");
      }
      else { /*It's a string*/
	int off;
	loadAddr("si",q.b);
	for (off=14;off>=0;off-=2) {
	  fprintf(fout,"\tmov\tax,word ptr [si%+d]\n",off);
	  fprintf(fout,"\tpush\tax\n");
	}
      }
    }
    else /*By Ref*/ {
      /*What happens if passing "boolean" by ref?*/
      loadAddr("si",q.b);
      fprintf(fout,"\tpush\tsi\n");
    }
  }
  else if (strcmp(q.a,"call")==0) {
    if (GetReturnType(Lookup(q.d,SEARCH_ALL_SCOPES))==VoidRet)
      fprintf(fout,"\tsub\tsp, 2\n");
    updateAL(q);
    fprintf(fout,"\tcall\tnear ptr %s\n",asmfuncname(q.d,tmpstr));
    fprintf(fout,"\tadd\tsp, %d\n",GetSizeOfArguments(Lookup(q.d,SEARCH_ALL_SCOPES))+4);


  } 
  else if (strcmp(q.a,"endu")==0) {
    fprintf(fout,"@%s:\n\tmov\tsp, bp\n",asmfuncname(q.b,tmpstr)+1);
    fprintf(fout,"\tpop\tbp\n");
    fprintf(fout,"\tret\n");
    fprintf(fout,"%s\tendp\n",asmfuncname(q.b,tmpstr));
  } 
  else if (strcmp(q.a,"jump")==0) {
    fprintf(fout,"\tjmp\t%s\n",label(atoi(q.d)));
  } 
  else if (strcmp(q.a,"ret")==0) {
    fprintf(fout,"\tjmp\t@%s\n",curunit+1);
  } 
  else if (strcmp(q.a,"retv")==0) {
    int type,intval;
    entry = Lookup(q.b, SEARCH_ALL_SCOPES);

    if (!entry) {  /*Constant or indexed string*/     
      if (isIstr(q.b)) {
	      char    *str;
	      char    *pos;

	      str = strname(q.b);
	      pos = strpos(q.b);

	      if (isStrC(str)) {
		if (!isIntC(pos)) {
		    fprintf(fout, "\tlea\tsi, %s\n",(freeme=newstring(str)));
		    free(freeme);
		    load("di", pos);
		    fprintf(fout,"\tadd\tsi, di\n");
		    fprintf(fout,"\tmov\tal, byte ptr [si]\n");
		    fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
		    fprintf(fout,"\tmov\tword ptr [si], al\n");
		} 
		else {
		  fprintf(fout,"\tmov\tal, %Xh\n",str2asc(str)[atoi(pos)]);
		  fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
		  fprintf(fout,"\tmov\tword ptr [si], al\n");
		}
	      }
	      else {
		loadAddr("si", str);
		load("di", pos);
		fprintf(fout,"\tadd\tsi, di\n");
		fprintf(fout,"\tmov\tal, byte ptr [si]\n");
		fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
		fprintf(fout,"\tmov\tword ptr [si], al\n");
	      } 
	      free(str); free(pos);
      } 
      else if (isIntC(q.b)) {
	fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
	fprintf(fout,"\tmov\tword ptr [si], %s\n",q.b);
      } 
      else if (isCharC(q.b)) {
	fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
	fprintf(fout,"\tmov\tbyte ptr [si],%s\n",cc2asc(q.b));
      } 
      else if (isBool(q.b,&intval)) {
	fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
	fprintf(fout,"\tmov\tbyte ptr [si], %d\n",intval);
      } 
      else if (isStrC(q.b)) {
	int off;
	char strtmp[20];
	  
	bzero(strtmp,sizeof(strtmp));
	memcpy(strtmp,str2asc(q.b),16);
	fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");

	for (off=14;off>=0;off-=2) {
	  fprintf(fout,"\tmov\tax, %04Xh\n ", (((int)q.b[15])<<8)+q.b[14]);
	  fprintf(fout,"\tmov\tword ptr [si%+d], ax\n",14-off);
	}
      } 
      else 
	fprintf(yyout,"Internal error #2980-4876:duplicate IP address\n");
      
    }
    else { /*if entry*/
	type = GetType(entry);
      if (type==IntegerType) {
	  load("ax", q.b);
	  fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
	  fprintf(fout,"\tmov\tword ptr [si], ax\n");
      } 
      else if (type==BooleanType||type==CharType) { 
	  load("al", q.b);
	  fprintf(fout,"\tmov\tsi, word ptr [bp+6]\n");
	  fprintf(fout,"\tmov\tbyte ptr [si], al\n");
      } 
      else {   /* It's a String*/
	  int off;
	  loadAddr("si", q.b);
	  fprintf(fout,"\tmov\tdi, word ptr [bp+6]");

	  for (off=14;off>=0;off-=2) {
	    fprintf(fout,"\tmov\tax, word ptr [si%+d]",off);
	    fprintf(fout,"\tmov\tword ptr [di%+d], ax",off);
	  }
      }
    } /*if entry*/
 
  } /*retv*/
}

void genasm()
{
  if (outasm)
    while (asmquad<nextquad)
      quad2asm(QUADS[asmquad++]);
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
printf("\nStarted\n");

	if (argc > 1) {
		if ((yyin = fopen(argv[1], "r")) == NULL) {
			perror(argv[1]);
			exit(2);
		}
	}
	if (argc > 2) {
		if ((fout = fopen(argv[2], "w")) == NULL) {
			perror(argv[2]);
			exit(3);
		}
	       
	}
	else fout=stdout;

	InitSymbolTable();

	if (yyparse()==0 && !errornum) printf("\nCODE OK!\n");
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
