all: russellex.l russelbis.tab.c russel

russellex.l: 
	  flex russellex.l

russelbis.tab.c: russelbis.y
	  bison -d russelbis.y

russel: russellex.l russelbis.y
	  gcc -o russel russelbis.tab.c lex.yy.c -lfl
