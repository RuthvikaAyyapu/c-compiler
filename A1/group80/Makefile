CXX   = g++-8
EXE = ipl_parser
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all clean
all: parser lexer 	
	$(CXX) $(CXXDEBUG) -o iplC driver.cpp parser.o scanner.o 

parser: parser.yy scanner.hh
	bison -d -v $<
	$(CXX) $(CXXDEBUG) -c parser.tab.cc -o parser.o 

lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX)  $(CXXDEBUG) -c scanner.yy.cc -o scanner.o

clean:
	rm parser.output parser.tab.cc parser.tab.hh parser.o scanner.o stack.hh position.hh location.hh iplC scanner.yy.cc
