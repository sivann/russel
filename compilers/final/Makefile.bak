all: russel

	
lex.yy.c: russellex.l russel.tab.h
	  @echo "Running flex...\c"
	  @echo "                flex russellex.l"
	  @flex russellex.l

russel.tab.h: russel.y
	  @echo "Running bison...\.c"
	  @echo "              bison -d -v russel.y"
	  @bison -d -v russel.y

bison: russel.tab.c
	
flex: lex.yy.c
	

russel.tab.c: russel.y
	  @echo "Running bison...\c"
	  @echo "               bison -d -v russel.y"
	  @bison -d -v russel.y

russel.tab.o: russel.tab.c
	 @echo "Compiling bison output...  \c"
	 @echo "    gcc -c -o russel.tab.o russel.tab.c"
	 @gcc -c -o russel.tab.o russel.tab.c

lex.yy.o: lex.yy.c
	 @echo "Compiling flex output...\c"
	 @echo "       gcc -c -o lex.yy.o lex.yy.c"
	 @gcc -c -o lex.yy.o lex.yy.c

russel: inter.o russel.tab.o lex.yy.o symbolc.o symbol.o
	  @echo "Linking objects...             \c"
	  @echo "inter.o russel.tab.o lex.yy.o symbolc.o symbol.o -lfl"
	  @gcc -o russel inter.o russel.tab.o lex.yy.o symbolc.o symbol.o -lfl
	  @echo ""
	  @echo "Complete!"
	
inter.o: inter.c inter.h
	@echo "Compiling inter.c..\c"
	@echo "            gcc -c -o inter.o inter.c
	@gcc -c -o inter.o inter.c

symbolc.o: symbolc.cpp
	@echo "Compiling symbol table decl.\c"
	@echo "   g++ -c -o symbolc.o symbolc.cpp"
	@g++ -c -o symbolc.o symbolc.cpp

symbol.o: symbol.cpp
	@echo "Compiling symbol table...\c"
	@echo "      g++ -c -o symbol.o symbol.cpp"
	@g++ -c -o symbol.o symbol.cpp

clean:
	rm -f lex.yy.c russel.tab.h russel.tab.c russel.output core
	rm -f inter.o lex.yy.o russel.tab.o 

cleanall: clean
	rm -f symbolc.o symbol.o 

