#include "symtab.hh"
#include <iostream>
using namespace std;


void SymTab::print(){

    cout<<"[";
    for(auto it=Entries.begin(); it!=Entries.end(); ++it){
        cout<<"[";
        cout<<"\""<<it->first<<"\",\t";
        cout<<"\""<<it->second.varfun<<"\",\t";
        cout<<"\""<<it->second.scope<<"\",\t";
        cout<<it->second.size<<",\t";
        if(it->second.varfun == "struct"){
            cout<<"\"-\",\t";
        }
        else{
            cout<<it->second.offset<<",\t";
        }
        cout<<"\""<<it->second.returntype<<"\"";
	cout<<"\n";
        cout<<"]";
        if(next(it,1)!=Entries.end()) cout<<","<<endl;
    }
    cout<<"\n]\n";
};


void SymTab::printlst(){

    cout<<"[\n";
    for(auto it=Entries.begin(); it!=Entries.end(); ++it){
        cout<<"[";
        cout<<"\""<<it->first<<"\",\t";
        cout<<"\""<<it->second.varfun<<"\",\t";
        cout<<"\""<<it->second.scope<<"\",\t";
        cout<<it->second.size<<",\t";
        if(it->second.varfun == "struct"){
            cout<<"\"-\",\t";
        }
        else{
            cout<<it->second.offset<<",\t";
        }
        cout<<"\""<<it->second.returntype<<"\"";
	cout<<"\n";
        cout<<"]\n";
        if(next(it,1)!=Entries.end()) cout<<","<<endl;
    }
    cout<<"]\n";
};

Entry::Entry(std::string varfun,std::string scope,int size,int offset,std::string returntype,SymTab *symtab){
    this->varfun = varfun;
    this->scope = scope;
    this->size = size;
    this->offset = offset;
    this->returntype = returntype;
    this->symbtab =symtab;
}
