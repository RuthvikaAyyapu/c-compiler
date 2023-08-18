%skeleton "lalr1.cc"
%require  "3.0.1"


%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{
	#include "symtab.hh"
	#include "ast.hh"
	#include "type.hh"
	#include "location.hh"
	namespace IPL {
	   class Scanner;
   	}

}


%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } INT_CONSTANT 
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } OTHERS


%parse-param { Scanner  &scanner  }
%locations

%code{
	#include <iostream>
	#include <cstdlib>
	#include <fstream>
	#include <string>
	#include <climits>
	#include <bits/stdc++.h>
	#include <algorithm>
	using namespace std;

 
	#include "scanner.hh"
	#undef yylex
	#define yylex IPL::Parser::scanner.yylex





	extern SymTab gst;
	std::map<std::string,abstract_astnode*>ast;
	SymTab* usage;
	int found_struct=0;
	int found_func=0;
	int uminus=0;
	int nott=0;
	std::string ast_kosam_return;
	std::string ast_kosam_fun;
	std::string err_name;
	std::string test;


}



%define api.value.type variant
%define parse.assert

%start translation_unit


%token <std::string> INT
%token <std::string> VOID
%token <std::string> FLOAT
%token <std::string> STRUCT
%token <std::string> RETURN
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> WHILE
%token <std::string> FOR
%token <std::string> IDENTIFIER
%token <std::string> INT_CONSTANT
%token <std::string> FLOAT_CONSTANT
%token <std::string> STRING_LITERAL
%token <std::string> OR_OP
%token <std::string> AND_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> PTR_OP
%token <std::string> INC_OP
%token <std::string> OTHERS
%token '{' '}' '(' ')' ',' ';' '[' ']' '*' '/' '>' '<' ':' '=' '+' '-' '.' '!' '&' 

%nonassoc  '='
%left OR_OP AND_OP EQ_OP NE_OP '<' LE_OP '>' GE_OP '+' '-' '*' '/' 
%right '&' USTAR UMINUS 
%left PTR_OP '.' INC_OP

%nterm <abstract_astnode*> translation_unit struct_specifier function_definition compound_statement;
%nterm <assignS_astnode*> assignment_statement;
%nterm <seq_astnode*> statement_list;
%nterm <assignE_astnode*> assignment_expression;
%nterm <exp_astnode*> logical_and_expression equality_expression relational_expression additive_expression multiplicative_expression unary_expression postfix_expression primary_expression expression;
%nterm <funcall_astnode*> expression_list;
%nterm <proccall_astnode*> procedure_call;
%nterm <std::string> unary_operator;

%nterm <statement_astnode*> selection_statement iteration_statement statement;
%nterm <parameter_declaration_class*>parameter_declaration;
%nterm <type_specifier_class*>type_specifier;
%nterm <declarator_class*> declarator declarator_arr;
%nterm <declaration_class*> declaration;
%nterm <declaration_list_class*> declaration_list;
%nterm <declarator_list_class*> declarator_list;
%nterm <fun_declarator_class*> fun_declarator;
%nterm <parameter_list_class*> parameter_list;



%%

translation_unit: 
	struct_specifier{}
    | function_definition{}
    | translation_unit struct_specifier{}
	| translation_unit function_definition{};

struct_specifier: 
	STRUCT IDENTIFIER '{'
    {
	err_name=$1;
        usage=new SymTab();
        found_struct=1;
    } 
    declaration_list '}' ';'
    {
        found_struct=0;
        gst.offset=gst.offset+usage->offset;
        Entry ste("struct","global",usage->offset,0,"-",usage);
	std::string ippudu ="struct "+$2;
        gst.Entries.insert({ippudu,ste});

    };
	

function_definition: 
	type_specifier{ast_kosam_return = $1->name;} fun_declarator compound_statement
	{
        found_func=0;
        Entry ste("fun","global",0,0,$1->name,usage);
        std::string ippudu=$3->name;
        gst.Entries.insert({ippudu,ste});
        ast.insert({$3->name,$4});
	}
	;

type_specifier: 
	VOID
    {
        $$=new type_specifier_class();
        $$->name="void";
        $$->size=4;
        $$->is_struct=0;
    }
        | INT
        {
            $$=new type_specifier_class();
        $$->name="int";
        $$->size=4;
        $$->is_struct=0;
        //ast_kosam_return="int";
        }
        | FLOAT
        {
            $$=new type_specifier_class();
        $$->name="float";
        $$->size=4;
        $$->is_struct=0;
        //ast_kosam_return="float";
        }
        | STRUCT IDENTIFIER
        {
	err_name=$1;
            $$=new type_specifier_class();
            $$->name="struct "+$2;
            int sz=gst.Entries.find($$->name)->second.size;
	$$->size=sz;
            $$->is_struct=1;
        };

fun_declarator: 
	IDENTIFIER '(' parameter_list ')'
    {	
	err_name=$1;
	
        //lets build the lhs class from the rhs
        $$ = new fun_declarator_class();
        $$->name = $1;
        $$->parameter_list = $3;
        //building node 
        usage = new SymTab();
        usage->offset = 12;
        found_func = 1;

        vector<parameter_declaration_class *> param_decls = $3->parameter_list;
        int sz = param_decls.size();
        parameter_declaration_class * decl;
        for(int i=1; i<sz+1; i++){
            decl = param_decls.at(sz-i);
            int product =1;
            for(const auto& e:decl->declarator->type.indices){
                product =product* e;
            }
            int a;
            if(decl->type_specifier->is_struct && decl->declarator->type.no_pointers > 0){
                a=4;
            }
            else{
                a = decl->type_specifier->size;                
            }
            int size_of_decl = a*product;
            int offset_of_decl = usage->offset;
            usage->offset = usage->offset + size_of_decl;

            std::string return_str = decl->type_specifier->name;
            for(int i=0; i<decl->declarator->type.no_pointers; i++){
                return_str = return_str+"*";
            }
            for(int i=0; (unsigned)i < decl->declarator->type.indices.size(); i++){
                return_str = return_str + "[";
                return_str = return_str + "decl->declarator->type.indices[i]";
                return_str = return_str + "]";
            }

              
            Entry entry("var", "param", size_of_decl, offset_of_decl, return_str, NULL);
            usage->Entries.insert({decl->declarator->name, entry});
        
        }

    usage->offset = 0;
    ast_kosam_fun = $1;

    }
        | IDENTIFIER '(' ')'{
	err_name=$1;
            $$ = new fun_declarator_class();
            $$->name = $1;
            $$->parameter_list = nullptr;

            usage = new SymTab();
            usage->offset = 0;
            found_func = 1;
            ast_kosam_fun = $1;
        };

parameter_list: 
	parameter_declaration{
        $$ = new parameter_list_class();
        $$->parameter_list.push_back($1);
    }

    | parameter_list ',' parameter_declaration{
        $$ = $1;
        $$->parameter_list.push_back($3);
    };

parameter_declaration: 
	type_specifier declarator{
	if($1->name=="void"){
	error(@$,"Cannot declare the type of a parameter as \" void \"");
	} 
        $$ = new parameter_declaration_class();
        $$->type_specifier = $1;
        $$->declarator = $2;
    };

declarator_arr: 
	IDENTIFIER{
	err_name=$1;
        $$ = new declarator_class();
        $$->name = $1;
        $$->type.no_pointers = 0;
    }
    | declarator_arr '[' INT_CONSTANT ']'{
        $$ = $1;
        int integ = stoi($3);
        $$->type.indices.push_back(integ);
    };

declarator: 
	declarator_arr{
        $$ = $1;
    }
    | '*' declarator{
        $$ = $2;
        $$->type.no_pointers = $$->type.no_pointers + 1;
    };

compound_statement: 
	'{' '}'{
        seq_astnode* temporary = new seq_astnode();
        temporary->astnode_type = typeExp::Seq_astnode;
        ast.insert({ast_kosam_fun, temporary});
    }
        | '{' statement_list '}'{
            ast.insert({ast_kosam_fun, $2});
        }
        |  '{' declaration_list '}'{
            seq_astnode* temporary = new seq_astnode();
            temporary->astnode_type = typeExp::Seq_astnode;
            ast.insert({ast_kosam_fun, temporary});
        }
        | '{' declaration_list statement_list '}'{
            ast.insert({ast_kosam_fun, $3});
        };

statement_list: 
	statement{
        $$ = new seq_astnode();
        $$->astnode_type = typeExp::Seq_astnode;
        $$->statements.push_back($1);
    }
    | statement_list statement{
        $1->statements.push_back($2);
        $$ = $1;
    };

statement: 
	';'{
        empty_astnode* temporary = new empty_astnode();
        temporary->astnode_type = typeExp::Empty_astnode;
        $$ = temporary;
    }
        | '{' statement_list '}'{
            $$ = $2;
        }
        | selection_statement{
            $$ = $1;
        }
        | iteration_statement{
            $$ = $1;
        }
        | assignment_statement{
            $$ = $1;
        }
        | procedure_call{
            $$ = $1;
        }
        | RETURN expression ';'{
	//cout<<ast_kosam_return;
	//cout<<$2->type;

	//cout<<$2->type;
            if($2->type == ast_kosam_return){
                return_astnode* temporary =new return_astnode();
                temporary->astnode_type = typeExp::Return_astnode;
                temporary->exp = $2;
                $$ = temporary;
            }
            else{
	 if((test == $2->type)&& (ast_kosam_return=="float") )
{error(@$,"Incompatible type \"string\" returned , expected \""+ast_kosam_return+"\"");}
                op_unary_astnode* other = new op_unary_astnode();
                other->astnode_type = typeExp::Op_unary_astnode;
                other->exp = $2;

                std::string s1 = ast_kosam_return;
                transform(s1.begin(), s1.end(), s1.begin(), ::toupper);
                other->op = "TO_"+s1;
                $2 = other;

                return_astnode* temporary = new return_astnode();
                temporary->astnode_type = typeExp::Return_astnode;
                temporary->exp = $2;
                $$ = temporary;
            }
        };

assignment_expression: 
	unary_expression '=' expression{
	if(uminus==1 && $1->type != $3->type){
	op_unary_astnode* other = new op_unary_astnode();
	other->astnode_type = typeExp:: Op_unary_astnode;
	if($3->type == "int"){
	std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            other->op = "TO_" + s1;
	other->exp=$3;
	uminus=0;
	$3=other;}
}
	if(nott==1){
	op_unary_astnode* other = new op_unary_astnode();
	other->astnode_type = typeExp:: Op_unary_astnode;

	std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            other->op = "TO_" + s1;
	other->exp=$3;
	nott=0;
	$3=other;
}
	//if(err_name=="i"){
	//error(@$,"Variable \""+err_name+"\" not declared");}
	if($1->type != $3->type){
	std::string neww = $3->type;
	int old =neww.length();
	auto it =std::find(neww.begin(),neww.end(),'*');
	if(it != neww.end())
	neww.erase(it);
	int newest = neww.length();
	
	 neww = $1->type;
	int old1 =neww.length();
	auto it1 =std::find(neww.begin(),neww.end(),'*');
	if(it1 != neww.end())
	neww.erase(it1);
	int new1 = neww.length();
	if((old1-new1) != (old-newest)){
	error(@$,"Incompatible assignment when assigning to type \"" + $1->type+"\" from type \"" +$3->type + "\"");}
	}
        $$ = new assignE_astnode();
        $$->astnode_type = typeExp::AssignE_astnode;
        $$->left = $1;
        $$->right=$3;
        

    };

assignment_statement: 
	assignment_expression ';'{
	
        $$ = new assignS_astnode();
	$$->astnode_type=typeExp::AssignS_astnode;
        $$->left = $1->left;
        $$->right =$1->right;
    };

procedure_call: 
	IDENTIFIER '(' ')' ';'{
	err_name=$1;
        exp_astnode* temporary =new identifier_astnode();
        temporary->type = $1;
        $$= new proccall_astnode();
        identifier_astnode* other= new identifier_astnode();
        other->name = $1;
        $$->fname = other;
	

    }
        | IDENTIFIER '(' expression_list ')' ';'{
	err_name=$1;
	/*
	if(gst.Entries.find($1)== gst.Entries.end()){
	error(@$,"Function \""+$1 +"\" not declared");}
	
	int no_args_actual = gst.Entries[$1].symbtab->Entries.size();
	int no_args_given = $3->args.size();
	if(no_args_given > no_args_actual){
	//cout<<"itu ochanandi";
	error(@$,"Procedure \""+$1 +"\" called with too many arguments");}
	*/
            exp_astnode* temporary =new identifier_astnode();
            temporary->type = $1;
            $$= new proccall_astnode();
            for(auto it = begin($3->args); it != end($3->args); ++it ){
                $$->args.push_back(*it);

            }
            identifier_astnode* other= new identifier_astnode();
        other->name = $1;
        $$->fname = other;
        };


expression: 
	logical_and_expression{$$=$1;}
        | expression OR_OP logical_and_expression{
            op_binary_astnode* temporary =new  op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            temporary->op = "OR_OP";
            temporary->type = "INT";
            $$ = temporary;

        };

logical_and_expression: 
	equality_expression{$$ = $1;}
        | logical_and_expression AND_OP equality_expression{
            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            temporary->op = "AND_OP";
            temporary->type = "INT";
            $$ = temporary;
        };
   
equality_expression: 
	relational_expression{$$=$1;}
        | equality_expression EQ_OP relational_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "EQ_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "EQ_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other =new  op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "EQ_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }




        }
        | equality_expression NE_OP relational_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "NE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary =new  op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "NE_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "NE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        };

relational_expression: 
	additive_expression{$$=$1;}
        | relational_expression '<' additive_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LT_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other =new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LT_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LT_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        }
        | relational_expression '>' additive_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GT_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other =new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GT_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other =new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GT_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        }
        | relational_expression LE_OP additive_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LE_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "LE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        }
        | relational_expression GE_OP additive_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other =new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GE_OP_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other =new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "GE_OP_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        };

additive_expression: 
	multiplicative_expression{$$ = $1;}
        | additive_expression '+' multiplicative_expression{
            //cout<<$3->type<<"and"<<$1->type<<endl;
	if(($3->type=="string" && ($1->type=="int" || $1->type=="INT")) ||($1->type=="string" && ($3->type=="int" || $3->type=="INT"))){
	error(@$,"Invalid operand types for binary + , \"" + $1->type+"\" and \"" +$3->type + "\"");
		}
	std::string le=$1->type;
	std::string ri=$3->type;
	//cout<<le;
	//cout<<ri;
	const char c=le[0];
	const char p=ri[0];
	if(c != p ){
	error(@$,"Invalid operand types for binary + , \"" + $1->type+"\" and \"" +$3->type + "\"");}
	if(($3->type=="void" && ($1->type=="int" || $1->type=="INT")) ||($1->type=="void" && ($3->type=="int" || $3->type=="INT"))){
	error(@$,"Invalid operand types for binary + , \"" + $1->type+"\" and \"" +$3->type + "\"");
		}
            if($3->type == $1->type){
                op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "PLUS_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "PLUS_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "PLUS_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        }
        | additive_expression '-' multiplicative_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MINUS_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary =new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MINUS_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MINUS_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        };


unary_expression: 
	postfix_expression{$$=$1;}
        | unary_operator unary_expression{
            op_unary_astnode* temporary = new op_unary_astnode();
            temporary->astnode_type = typeExp::Op_unary_astnode;
            temporary->exp = $2;
            temporary->op = $1;
            if($1 == "UMINUS"){
                temporary->type= $2->type;
		uminus=1;
            }
            if($1=="NOT"){
                temporary->type=$2->type;
		nott=1;
            }
            if($1=="ADDRESS"){
	temporary->type=$2->type;
	
		}
            if($1=="DEREF"){
		if($2->type == "int"){
		error(@$,"Invalid operand type \"int\" of unary *");}
                std::string neww=$2->type;
                auto it=std::find(neww.begin(), neww.end(), '*');
                if (it != neww.end()) neww.erase(it);
                temporary->type=neww;
            }

            $$=temporary;
        
        };


multiplicative_expression: 
	unary_expression{$$ = $1;}
        | multiplicative_expression '*' unary_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary =new  op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MULT_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MULT_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "MULT_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        }
        | multiplicative_expression '/' unary_expression{
            if($3->type == $1->type){
                op_binary_astnode* temporary =new  op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "DIV_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $1->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $1;
            other->op="TO_FLOAT";
            $1=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $3->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "DIV_" + s1;
            temporary->type = $3->type;
            $$ = temporary;
            }

            if($3->type != $1->type && $3->type=="int"){
                op_unary_astnode* other = new op_unary_astnode();
            other->astnode_type = typeExp::Op_unary_astnode;
            other->exp = $3;
            other->op="TO_FLOAT";
            $3=other;

            op_binary_astnode* temporary = new op_binary_astnode();
            temporary->astnode_type = typeExp::Op_binary_astnode;
            temporary->left = $1;
            temporary->right=$3;
            
            std::string s1= $1->type;
            transform(s1.begin(),s1.end(),s1.begin(),::toupper);
            temporary->op = "DIV_" + s1;
            temporary->type = $1->type;
            $$ = temporary;
            }
        };

postfix_expression: 
	primary_expression
    {
        $$= $1;
    }
        | postfix_expression '[' expression ']'
        {
            arrayref_astnode* temporary = new arrayref_astnode();
            temporary->astnode_type = typeExp::Arrayref_astnode;
            temporary->array=$1;
            temporary->index=$3;
            std::string name=$1->type;
            string s;
            vector<std::string> pieces;
            int i=0;
            while (name[i] != '\0'){
                if (name[i] != '[' ){
                    s += name[i];
                } else{
                    pieces.push_back(s);
                    string bra="[";
                    pieces.push_back(bra);
                    s.clear();
                }
                i++;
            }
            int sz=pieces.size();
            string p;
            for (int i=0;i<sz-1;i++){
                p=p+pieces.at(i);
            }
            temporary->type=p;
            $$=temporary;
        }
        | IDENTIFIER '(' ')'
        {
		err_name=$1;
            identifier_astnode* iden = new identifier_astnode();
            iden->astnode_type = typeExp::IDENTIFIER_astnode;
            iden->name=$1;
            funcall_astnode* temporary = new funcall_astnode();
            temporary->astnode_type = Funcall_astnode;
            identifier_astnode* other=new identifier_astnode();
            other->name=$1;
            temporary->fname=other;
            $$=temporary;
        }
        | IDENTIFIER '(' expression_list ')'
        {
	err_name=$1;
            identifier_astnode* iden= new identifier_astnode();
            iden->astnode_type= typeExp::IDENTIFIER_astnode;
            iden->name = $1;
            funcall_astnode* temporary = new funcall_astnode();
            temporary->astnode_type = Funcall_astnode;
            identifier_astnode* other= new identifier_astnode();
            other->name = $1;
            temporary->fname = other;
            for(auto& it: $3->args){
                temporary->args.push_back(it);
            }
            $$ = temporary;
        }
        | postfix_expression '.' IDENTIFIER
        {
            identifier_astnode* iden = new identifier_astnode();
            iden->astnode_type = typeExp::IDENTIFIER_astnode;
            iden->name= $3;
            member_astnode* temporary = new member_astnode();
            temporary->astnode_type = typeExp::Member_astnode;
            temporary->exp = $1;
            temporary->member= iden;
            $$ = temporary;
	err_name=$3;
        }
        | postfix_expression PTR_OP IDENTIFIER
        {
            identifier_astnode* iden = new identifier_astnode();
            iden->astnode_type = typeExp:: IDENTIFIER_astnode;
            iden->name = $3;
            arrow_astnode* temporary = new arrow_astnode();
            temporary->astnode_type = typeExp::Arrow_astnode;
            temporary->exp = $1;
            temporary->member = iden;
            $$ = temporary;
		err_name=$3;
        }
        | postfix_expression INC_OP
        {
            op_unary_astnode* temporary = new op_unary_astnode();
            temporary->astnode_type = typeExp::Op_unary_astnode;
            temporary->exp = $1;
            temporary->op = "PP";
            temporary->type = $1->type;
            $$ = temporary;
        };

primary_expression: 
	IDENTIFIER
    {
        identifier_astnode* iden = new identifier_astnode();
        iden->astnode_type = typeExp::IDENTIFIER_astnode;
        iden->name=$1;
        $$ = iden;
        std::string neww=usage->Entries[$1].returntype;
        $$->type=neww;
	err_name=$1;
    }
        | INT_CONSTANT
        {
            int c=std::stoi($1);
            intconst_astnode* temporary = new intconst_astnode();
            temporary->astnode_type = typeExp::Intconst_astnode;
            temporary->value=c;
            temporary->type="int";
            $$=temporary;
        }
        | FLOAT_CONSTANT
        {
            float c=std::stof($1);
            floatconst_astnode* temporary = new floatconst_astnode();
            temporary->astnode_type = typeExp::Floatconst_astnode;
            temporary->value=c;
            temporary->type = "float";
            $$=temporary;
        }
        | STRING_LITERAL
        {
            stringconst_astnode* temporary = new stringconst_astnode();
            temporary->astnode_type = typeExp::Stringconst_astnode;
            temporary->value=$1;
	temporary->type = "string";
	test=$1;
	
            $$=temporary;
        }
        | '(' expression ')'
        {
            $$ = $2;
        };

expression_list: 
	expression
    {
        funcall_astnode* temporary = new funcall_astnode();
        temporary->astnode_type = typeExp::Funcall_astnode;
        temporary->args.push_back($1);
        identifier_astnode* other = new identifier_astnode();
        other->name=$1->type;
        temporary->fname=other;
        $$=temporary;
    }
        | expression_list ',' expression
        {
            $1->args.push_back($3);
            $$ = $1;
        };

unary_operator: 
	'-'
    {
        $$ = "UMINUS";
    }
        | '!'
        {
            $$ = "NOT";
        }
        | '&'
        {
            $$ = "ADDRESS";
        }
        | '*'
        {
            $$ = "DEREF";
        };

selection_statement: 
	IF '(' expression ')' statement ELSE statement{
    if_astnode* noww= new if_astnode();
    noww->astnode_type = typeExp::If_astnode;
    noww->condition=$3;
    noww->then=$5;
    noww->else1=$7;
    $$=noww;
};

iteration_statement: 
	WHILE '(' expression ')' statement
    {
    while_astnode* noww = new while_astnode();
    noww->astnode_type = typeExp::While_astnode;
    noww->condition=$3;
    noww->body=$5;
    $$=noww;
    }
        | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement
        {
            for_astnode* noww = new for_astnode();
            noww->astnode_type = typeExp::For_astnode;
            noww->init=$3;
            noww->condition=$5;
            noww->update=$7;
            noww->body=$9;
            $$ = noww;
        };

declaration_list: 
	declaration{
        $$ = new declaration_list_class();
        $$->declaration_list.push_back($1);

    


    }
        | declaration_list declaration{
            $$=$1;
            $$->declaration_list.push_back($2);
        }

declaration: 
	type_specifier declarator_list ';'{
        $$=new declaration_class();
        $$->type_specifier=$1;
        $$->declarator_list=$2;
        if($1->name=="void"){
	error(@$,"Cannot declare variable of type \" void \"");
	}    
	if(found_struct){
	std::vector<declarator_class*> declars=$2->declarator_list;
	for(auto decl:declars){
        int product=1;
        for(const auto& e:decl->type.indices){product *= e;}
        int a;
        if($1->is_struct && decl->type.no_pointers>0){
        a=4;}
        else{
            a=$1->size;
        }
	int size_of_decl=a*product;
        int offset_of_decl =usage->offset;
        usage->offset=usage->offset+size_of_decl;
        std::string return_str=$1->name;
        for(int i=0;i<decl->type.no_pointers;i++){
            return_str=return_str+"*";
        }
        for(int i=0;(unsigned)i<decl->type.indices.size();i++){
            return_str=return_str+"[";
            return_str=return_str+to_string(decl->type.indices[i]);
            return_str=return_str+"]";
        }
        Entry entry("var","local",size_of_decl,offset_of_decl,return_str,NULL);
        usage->Entries.insert({decl->name,entry});
        }
    }

    if(found_func){
    std::vector<declarator_class*> declars=$2->declarator_list;
    for(auto decl:declars){
        int product=1;
        for(const auto& e:decl->type.indices){product *= e;}
        int a;
        if($1->is_struct && decl->type.no_pointers>0){
        a=4;}
        else{
            a=$1->size;
        }int size_of_decl=a*product;
        usage->offset=(usage->offset)-size_of_decl;
        int offset_of_decl =usage->offset;
        
        std::string return_str=$1->name;
        for(int i=0;i<decl->type.no_pointers;i++){
            return_str=return_str+"*";
        }
        for(int i=0;(unsigned)i<decl->type.indices.size();i++){
            return_str=return_str+"[";
            return_str=return_str+to_string(decl->type.indices[i]);
            return_str=return_str+"]";
        }
        Entry entry("var","local",size_of_decl,offset_of_decl,return_str,NULL);
        usage->Entries.insert({decl->name,entry});
        }
    }

};




declarator_list: 
	declarator{
        $$= new declarator_list_class();
        $$->declarator_list.push_back($1);
    }
        | declarator_list ',' declarator{
            $$ = $1;
            $$->declarator_list.push_back($3);
        };
%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " <<l.begin.line<<": "<< err_message <<"\n";
	exit(1);
}

