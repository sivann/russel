%{
#define TK_EOF			0
#define	TK_ID			1
#define	TK_INT			2
#define TK_CHAR			3
#define TK_STR			4
#define TK_COMMA		5
#define TK_PLUS			6
#define TK_MINUS		7
#define TK_MULTI		8
#define TK_ASSGN		9
#define TK_LT			10
#define TK_LE			11
#define TK_EQ			12
#define TK_NE			13
#define TK_GT			14
#define TK_GE			15
#define TK_COL			16
#define TK_THEN			17
#define TK_ELSE			18
#define TK_BRACKET_OPEN		19
#define TK_BRACKET_CLOSE	20
#define TK_PAR_OPEN		21
#define TK_PAR_CLOSE		22
#define	KEYW_AND		23
#define	KEYW_BOOLEAN		24
#define KEYW_CHAR		25
#define KEYW_DIV		26
#define KEYW_DO			27
#define KEYW_END		28
#define KEYW_FALSE		29
#define KEYW_FUNCTION		30
#define KEYW_IF			31
#define KEYW_INTEGER		32
#define KEYW_IS			33
#define KEYW_MOD		34
#define KEYW_NOT		35
#define KEYW_OR			36
#define KEYW_REF		37
#define KEYW_RETURN		38
#define KEYW_STRING		39
#define KEYW_TRUE		40
#define KEYW_VAR		41
#define TK_UNKNOWN		42

char	*msg[] = {
	"EOF",
	"Identifier ",
	"Integer ",
	"Character ",
	"String ",
	"Comma ",
	"OpPlus ",
	"OpMinus ",
	"OpMulti ",
	"OpAssign ",
	"OpLowerThan",
	"OpLowerEqual",
	"OpEqual",
	"OpNotEqual",
	"OpGreaterThan",
	"OpGreaterEqual",
	"Column",
	"Then",
	"Else",
	"OpenningBracket",
	"ClosingBracket",
	"OpeningParenthesis",
	"ClosingParenthesis",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"Keyword ",
	"UnknownCharacter",
};

int	linenum = 1;

%}

white	[ \t]
newline	[\n]
letter	[A-Za-z]
digit	[0-9]
esc	[\\][nt\'\"0\\]
ispr	[^\x00-\x1f\'\"]


%%

{white}+				{ /* nothing */ }
"and"					{ return KEYW_AND; }
"boolean"				{ return KEYW_BOOLEAN; }
"char"					{ return KEYW_CHAR; }
"div"					{ return KEYW_DIV; }
"do"					{ return KEYW_DO; }
"end"					{ return KEYW_END; }
"false"					{ return KEYW_FALSE; }
"function"				{ return KEYW_FUNCTION; }
"if"					{ return KEYW_IF; }
"integer"				{ return KEYW_INTEGER; }
"is"					{ return KEYW_IS; }
"mod"					{ return KEYW_MOD; }
"not"					{ return KEYW_NOT; }
"or"					{ return KEYW_OR; }
"ref"					{ return KEYW_REF; }
"return"				{ return KEYW_RETURN; }
"string"				{ return KEYW_STRING; }
"true"					{ return KEYW_TRUE; }
"var"					{ return KEYW_VAR; }


{newline}				{ linenum++; }
{letter}({letter}|{digit})*		{ return TK_ID; }
{digit}+				{ return TK_INT; }
"\""({ispr}|{esc}){0,16}"\""		{ return TK_STR; }
"\'"({ispr}|{esc})"\'"		        { return TK_CHAR; }

"->"					{ return TK_THEN; }
"+"					{ return TK_PLUS; }
"-"					{ return TK_MINUS; }
"*"					{ return TK_MULTI; }
","					{ return TK_COMMA; }

"("					{ return TK_PAR_OPEN; }
")"					{ return TK_PAR_CLOSE; }
"["					{ return TK_BRACKET_OPEN; }
"]"					{ return TK_BRACKET_CLOSE; }

"="					{ return TK_EQ; }
"<>"					{ return TK_NE; }
"<="					{ return TK_LE; }
">="					{ return TK_GE; }
"<"					{ return TK_LT; }
">"					{ return TK_GT; }

":="					{ return TK_ASSGN; }
":"					{ return TK_COL; }
"|"					{ return TK_ELSE; }

"{"([^}]|{newline})*"}"			{ }

%%

int main () {
	int	token;
	
	while ((token = yylex())!=TK_EOF) {
		printf("line %02d: %25s\t%s\n",linenum,msg[token], yytext);
	}
}
