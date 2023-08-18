#ifndef AST_HH
#define AST_HH
#include"type.hh"
#include<vector>
#include<string>
using namespace std;
enum typeExp
{
    Empty_astnode,
    Seq_astnode,
    AssignS_astnode,
    Return_astnode,
    If_astnode,
    While_astnode,
    For_astnode,
    Proccall_astnode,
    Op_binary_astnode,
    Op_unary_astnode,
    AssignE_astnode,
    Funcall_astnode,
    Intconst_astnode,
    Floatconst_astnode,
    Stringconst_astnode,
    IDENTIFIER_astnode,
    Arrayref_astnode,
    Member_astnode,
    Arrow_astnode,
};



class abstract_astnode{
    public:
    virtual void print(int blanks)=0;
    enum typeExp astnode_type;
};

class statement_astnode: public abstract_astnode{
    public:
    virtual void print(int blanks)=0;
    abstract_astnode* state;

};
class exp_astnode:public abstract_astnode{
    public:
    virtual void print(int blanks)=0;
    string type;
    abstract_astnode* exp;

};

class ref_astnode:public exp_astnode{
    public:
    virtual void print(int blanks)=0;
    abstract_astnode* ref;
};
class identifier_astnode:public ref_astnode{
    public:
    
    std::string name;
    void print(int blanks);
};

class arrayref_astnode:public ref_astnode{
    public:
    exp_astnode* array;
    exp_astnode* index;
    void print(int blanks);
};
class member_astnode:public ref_astnode{
    public:
    exp_astnode* exp;
    identifier_astnode* member;
    void print(int blanks);
};
class arrow_astnode:public ref_astnode{
    public:
    exp_astnode* exp;
    identifier_astnode* member;
    void print(int blanks);
};
class empty_astnode:public statement_astnode{
    public:
    void print(int blanks);
};
class seq_astnode:public statement_astnode{
    public:
    std::vector<statement_astnode*> statements;
    void print(int blanks);
};
class assignS_astnode:public statement_astnode{
    public:
    exp_astnode* left;
    exp_astnode* right;
    void print(int blanks);
};
class return_astnode:public statement_astnode{
    public:
    exp_astnode* exp;
    void print(int blanks);
};


class if_astnode:public statement_astnode{
    public:
    exp_astnode* condition;
    statement_astnode* then;
    statement_astnode* else1;
    void print(int blanks);

};
class while_astnode:public statement_astnode{
    public:
    exp_astnode* condition;
    statement_astnode* body;
    void print(int blanks);
};

class for_astnode:public statement_astnode{
	public:
    exp_astnode* init;
    exp_astnode* condition;
    exp_astnode* update;
    statement_astnode* body;
    void print(int blanks);
};

class proccall_astnode:public statement_astnode{
    public:
    std::vector<exp_astnode*> args;
    void print(int blanks);
    identifier_astnode* fname;
};
class op_binary_astnode:public exp_astnode{
    public:
    std::string op;
    exp_astnode* left;
    exp_astnode* right;
    void print(int blanks);
};
class op_unary_astnode:public exp_astnode{
    public:
    std::string op;
    exp_astnode* exp;
    void print(int blanks);
};
class assignE_astnode:public exp_astnode{
    public:
    exp_astnode* left;
    exp_astnode* right;
    void print(int blanks);
};
class funcall_astnode:public exp_astnode{
    public:
    std::vector<exp_astnode*> args;
    void print(int blanks);
    identifier_astnode* fname;
};
class intconst_astnode:public exp_astnode{
    public:
    int value;
    void print(int blanks);
};
class floatconst_astnode:public exp_astnode{
    public:
    float value;
    void print(int blanks);
};
class stringconst_astnode:public exp_astnode{
    public:
    std::string value;
    void print(int blanks);
};

#endif
