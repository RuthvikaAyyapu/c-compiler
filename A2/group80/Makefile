CXX   = g++-8
EXE = ipl_parser
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all clean
all: parser lexer type.cpp symtab.cpp ast.cpp
	$(CXX) $(CXXDEBUG) -o iplC main.cpp parser.o scanner.o type.cpp symtab.cpp ast.cpp 

parser: parser.yy scanner.l scanner.hh
	bison -d -v $<
	$(CXX) $(CXXDEBUG) -c parser.tab.cc -o parser.o 

lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX)  $(CXXDEBUG) -c scanner.yy.cc -o scanner.o

clean:
	rm -f *.o *.tab.* *.yy.* *.output iplC location.hh position.hh stack.hh
