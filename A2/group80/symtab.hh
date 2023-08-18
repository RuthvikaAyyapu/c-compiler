#ifndef SYMTAB_HH
#define SYMTAB_HH

#include <iostream>
#include <map>
#include <string>
using namespace std;

class SymTab;
class Entry;

class Entry{
    public:
    std::string varfun;
    std::string scope;
    std::string returntype;
    int size;
    int offset;
    SymTab *symbtab;
    Entry(){}
    Entry(std::string varfun,std::string scope,int size, int offset,std::string returntype,SymTab *symtab);

};


class SymTab{
    public:
    std::map<std::string,Entry> Entries;
    int offset;
    void print();
    void printlst();
    SymTab(){
        offset=0;
    }
};



#endif




