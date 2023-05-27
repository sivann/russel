all: russel

	
lex.yy.c: russellex.l russel.tab.h
	  @echo "Running flex..."
	  @flex russellex.l

russel.tab.h: russel.y
	  @echo "Running bison..."
	  @bison -d -v russel.y

russel.tab.c: russel.y
	  @echo "Running bison..."
	  @bison -d -v russel.y

russel: inter.o russel.tab.c lex.yy.c symbolc.o symbol.o
	  @echo "Compiling russel..."
	  @gcc -o russel inter.c russel.tab.c lex.yy.c symbolc.o symbol.o -lfl
	  @echo ""
	  @echo "Complete!"
	
inter.o: inter.c inter.h
	@echo "Compiling inter.c"
	@gcc -c -o inter.o inter.c

symbolc.o: symbolc.cpp
	@echo "Compiling symbol table declarations..."
	@g++ -c -o symbolc.o symbolc.cpp

symbol.o: symbol.cpp
	@echo "Compiling symbol table..."
	@g++ -c -o symbol.o symbol.cpp

clean:
	rm -f lex.yy.c russel.tab.h russel.tab.c inter.o russel.output core

cleanall: clean
	rm -f symbolc.o symbol.o 
