#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "inter.h"

extern int      linenum;
extern FILE     *yyout;

int     nextquad = 1;
QUAD    QUADS[2000];

LIST *makelist(int label) {
        LIST    *l = (LIST*)malloc(sizeof(LIST));
        l->next = NULL;
        l->label = label;
        return l;
}

LIST *merge(LIST *l1, LIST *l2) {
        LIST    *head;
        if (l1==NULL) return l2;
        head = l1;
        while (l1->next!=NULL)  l1 = l1->next;
        l1->next = l2;
        return head;
}

backpatch(LIST *l, int val) {
        LIST    *tmp;
        char    quad4[256];

        sprintf(quad4, "%d", val);
        while (l!=NULL) {
                free(QUADS[l->label].d);
                QUADS[l->label].d = strdup(quad4);
                tmp = l;
                l = l->next;
                free(tmp);
        }

        return 0;
}

genquad(char *a, char *b, char *c, char *d) {
        
        QUADS[nextquad].a = (char *) strdup(a);
        QUADS[nextquad].b = (char *) strdup(b);
        QUADS[nextquad].c = (char *) strdup(c);
        QUADS[nextquad].d = (char *) strdup(d);
        nextquad++;
        return nextquad;
}

discardicode() {
        int     i;

        for (i=1; i<nextquad; i++) {
                free(QUADS[i].a);
                free(QUADS[i].b);
                free(QUADS[i].c);
                free(QUADS[i].d);
        }
        return 0;
}

printicode() {
        int     i;

        for (i=1; i<nextquad; i++)
                fprintf(yyout, "%6d:  %s, %s, %s, %s\n", i,
                       QUADS[i].a, QUADS[i].b, QUADS[i].c, QUADS[i].d);
        return 0;
}
