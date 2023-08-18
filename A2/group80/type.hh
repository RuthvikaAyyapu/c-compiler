#ifndef TYPE_HH
#define TYPE_HH
#include <vector>
#include <string>


class datatype{
    public:
    int no_pointers;
    std::vector<int> indices;
};

class declarator_class{
    public:
    std::string name;
    datatype type;

};
 
class declarator_list_class{
    public:
    std::vector<declarator_class*> declarator_list;
};
 class type_specifier_class{
     public:
     int size;
     int is_struct;
     std::string name;
 };


 class declaration_class{
     public:
     type_specifier_class *type_specifier;
     declarator_list_class *declarator_list;

 };
  
class declaration_list_class{
    public:
    std::vector<declaration_class*> declaration_list;
};

class parameter_declaration_class{
    public:
    type_specifier_class *type_specifier;
    declarator_class *declarator;
};

class parameter_list_class{
    public:
    std::vector<parameter_declaration_class*> parameter_list;

};


class fun_declarator_class{
    public:
    std::string name;
    parameter_list_class *parameter_list;
};


#endif
