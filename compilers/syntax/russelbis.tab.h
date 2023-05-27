#ifndef YYSTYPE
#define YYSTYPE int
#endif
#define	TK_ID	1
#define	TK_INT	2
#define	TK_CHAR	3
#define	TK_STR	4
#define	TK_COMMA	5
#define	TK_PLUS	6
#define	TK_MINUS	7
#define	TK_MULTI	8
#define	TK_ASSGN	9
#define	TK_LT	10
#define	TK_LE	11
#define	TK_EQ	12
#define	TK_NE	13
#define	TK_GT	14
#define	TK_GE	15
#define	TK_COL	16
#define	TK_THEN	17
#define	TK_ELSE	18
#define	TK_BRACKET_OPEN	19
#define	TK_BRACKET_CLOSE	20
#define	TK_PAR_OPEN	21
#define	TK_PAR_CLOSE	22
#define	KEYW_AND	23
#define	KEYW_BOOLEAN	24
#define	KEYW_CHAR	25
#define	KEYW_DIV	26
#define	KEYW_DO	27
#define	KEYW_END	28
#define	KEYW_FALSE	29
#define	KEYW_FUNCTION	30
#define	KEYW_IF	31
#define	KEYW_INTEGER	32
#define	KEYW_IS	33
#define	KEYW_MOD	34
#define	KEYW_NOT	35
#define	KEYW_OR	36
#define	KEYW_REF	37
#define	KEYW_RETURN	38
#define	KEYW_STRING	39
#define	KEYW_TRUE	40
#define	KEYW_VAR	41
#define	UNARY	258


extern YYSTYPE yylval;
