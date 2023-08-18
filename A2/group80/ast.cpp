#include "ast.hh"
#include <iostream>
#include <cstdarg>
using namespace std;

void printAst(const char *astname, const char *fmt...) // fmt is a format string that tells about the type of the arguments.
{   
	typedef vector<abstract_astnode *>* pv;
	va_list args;
	va_start(args, fmt);
	if ((astname != NULL) && (astname[0] != '\0'))
	{
		cout << "{ ";
		cout << "\"" << astname << "\"" << ": ";
	}
	cout << "{" << endl;
	while (*fmt != '\0')
	{
		if (*fmt == 'a')
		{
			char * field = va_arg(args, char *);
			abstract_astnode *a = va_arg(args, abstract_astnode *);
			cout << "\"" << field << "\": " << endl;
			
			a->print(0);
		}
		else if (*fmt == 's')
		{
			char * field = va_arg(args, char *);
			char *str = va_arg(args, char *);
			cout << "\"" << field << "\": ";

			cout << str << endl;
		}
		else if (*fmt == 'i')
		{
			char * field = va_arg(args, char *);
			int i = va_arg(args, int);
			cout << "\"" << field << "\": ";

			cout << i;
		}
		else if (*fmt == 'f')
		{
			char * field = va_arg(args, char *);
			double f = va_arg(args, double);
			cout << "\"" << field << "\": ";
			cout << f;
		}
		else if (*fmt == 'l')
		{
			char * field = va_arg(args, char *);
			pv f =  va_arg(args, pv);
			cout << "\"" << field << "\": ";
			cout << "[" << endl;
			for (int i = 0; i < (int)f->size(); ++i)
			{
				(*f)[i]->print(0);
				if (i < (int)f->size() - 1)
					cout << "," << endl;
				else
					cout << endl;
			}
			cout << endl;
			cout << "]" << endl;
		}
		++fmt;
		if (*fmt != '\0')
			cout << "," << endl;
	}
	cout << "}" << endl;
	if ((astname != NULL) && (astname[0] != '\0'))
		cout << "}" << endl;
	va_end(args);
}

void empty_astnode::print(int blank){
    cout << "\"empty\"" << endl;
}
void seq_astnode::print(int blank){
    printAst("","l","seq",statements);
};
void assignS_astnode::print(int blank){
    printAst("assignS","aa","left",left,"right",right);
};
void return_astnode::print(int blank){
    printAst("","a","return",exp);
};

void if_astnode::print(int blank){
    printAst("if","aaa","cond",condition,"then",then,"else",else1);
}

void while_astnode::print(int blank){
    printAst("while","aa","cond",condition,"stmt",body);
}
void for_astnode::print(int blank){
    printAst("for","aaaa","init",init,"guard",condition,"step",update,"body",body);

}

void proccall_astnode::print(int blank){
    printAst("proccall","al","fname",fname,"params",args);
}

void op_binary_astnode::print(int blank){
    string neww = "\""+op;
    neww=neww+"\"";
    char* str1 = const_cast<char*>(neww.c_str());
    printAst("op_binary","saa","op",str1,"left",left,"right",right);
}

void op_unary_astnode::print(int blank){
    string neww = "\""+op;
    neww=neww+"\"";
    char* str1 = const_cast<char*>(neww.c_str());
    printAst("op_unary","sa","op",str1,"child",exp);
}

void assignE_astnode::print(int blank){
    printAst("assignE","aa","left",left,"right",right);
}

void funcall_astnode::print(int blank){
    printAst("funcall","al","fname",fname,"params",args);
}

void intconst_astnode::print(int blank){
    printAst("","i","intconst",value);
}
void floatconst_astnode::print(int blank){
    printAst("","f","floatconst",value);
}
void stringconst_astnode::print(int blank){
    char* neww =  const_cast<char*>(value.c_str());
    printAst("","s","stringconst",neww);
}
void identifier_astnode::print(int blank){
    string neww= "\""+name;
    neww= neww+"\"";
    char* str1 =  const_cast<char*>(neww.c_str());
    printAst("","s","identifier",str1);

}
void arrayref_astnode::print(int bank){
    printAst("arrayref","aa","array",array,"index",index);
}
void member_astnode::print(int blank){
    printAst("member","aa","struct",exp,"field",member);
}
void arrow_astnode::print(int blank){
    printAst("arrow","aa","pointer",exp,"field",member);
}

