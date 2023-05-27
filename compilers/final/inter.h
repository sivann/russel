#ifndef __ICODE__
#define __ICODE__


typedef struct LIST *listp;

typedef struct LIST {
        listp   next;
        int     label;
} LIST;

typedef struct QUAD {
        char    *a, *b, *c, *d;
	int	no;
} QUAD;

extern int     nextquad;
extern QUAD    QUADS[2000];


extern LIST *makelist(int);
extern LIST *merge(LIST *, LIST *);
extern backpatch(LIST *, int);
extern genquad(char *, char *, char *, char *);
extern discardicode();
extern printicode();

#endif
