#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "tree.h"
extern int line_num;  
extern FILE* yyin;

// tipos de simbolo
typedef enum {
    SYMBOL_VARIABLE,   
    SYMBOL_ARRAY,       
    SYMBOL_FUNCTION    
} SymbolType;

// tipos de dados
typedef enum {
    TYPE_INT,          
    TYPE_VOID      
} DataType;

typedef struct SymbolEntry {
    char *name;             
    SymbolType symbol_type;  
    DataType data_type;      
    int array_size;          
    int num_params;        
    DataType *param_types;   
    int scope_level;     
    struct SymbolEntry *next;
} SymbolEntry;

typedef struct {
    SymbolEntry *entries;   
    int current_scope;    
} SymbolTable;

SymbolTable *symbol_table;

// declarações de funcao
SymbolEntry* create_symbol(char *name, SymbolType sym_type, DataType data_type, int scope);
bool insert_symbol(SymbolEntry *entry);
SymbolEntry* lookup_symbol(char *name, int scope);
void semantic_error(const char *message, int line_num);
void analyze_node(TreeNode *node, int scope);
bool is_type_compatible(DataType type1, DataType type2);

SymbolEntry* create_symbol(char *name, SymbolType sym_type, DataType data_type, int scope) {
    SymbolEntry *entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    entry->name = strdup(name);
    entry->symbol_type = sym_type;
    entry->data_type = data_type;
    entry->array_size = 0;
    entry->num_params = 0;
    entry->param_types = NULL;
    entry->scope_level = scope;
    entry->next = NULL;
    return entry;
}
//input e output do cminus
void add_built_in_functions(SymbolTable *table) {
    // Adiciona função input()
    SymbolEntry *input_func = create_symbol("input", SYMBOL_FUNCTION, TYPE_INT, 0);
    input_func->num_params = 0;
    insert_symbol(input_func);

    // Adiciona função output()
    SymbolEntry *output_func = create_symbol("output", SYMBOL_FUNCTION, TYPE_VOID, 0);
    output_func->num_params = 1;
    output_func->param_types = (DataType*)malloc(sizeof(DataType));
    output_func->param_types[0] = TYPE_INT;
    insert_symbol(output_func);
}

SymbolTable* init_symbol_table() {
    SymbolTable *table = (SymbolTable*)malloc(sizeof(SymbolTable));
    table->entries = NULL;
    table->current_scope = 0;
    return table;
}

// Busca simbolo
SymbolEntry* lookup_symbol(char *name, int scope) {
    SymbolEntry *current = symbol_table->entries;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0 && current->scope_level <= scope) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}


bool insert_symbol(SymbolEntry *entry) {
 
    SymbolEntry *existing = lookup_symbol(entry->name, entry->scope_level);
    if (existing != NULL && existing->scope_level == entry->scope_level) {
        return false;  // simbolo ja ta declarado
    }

    entry->next = symbol_table->entries;
    symbol_table->entries = entry;
    return true;
}

// Relatório de erro semântico
void semantic_error(const char *message, int line_num) {
    fprintf(stderr, "ERRO SEMANTICO: %s LINHA: %d \n", message, line_num);
}


bool is_type_compatible(DataType type1, DataType type2) {
    if (type1 == TYPE_VOID || type2 == TYPE_VOID) {
        return false;
    }
    return true;
}

// declaracao de var
void analyze_var_declaration(TreeNode *node, int scope) {
    if (!node) return;

    DataType type = (strcmp(node->children[0]->value, "int") == 0) ? TYPE_INT : TYPE_VOID;
    SymbolType sym_type = SYMBOL_VARIABLE;
    
    //e array?
    if (node->num_children > 2) {
        sym_type = SYMBOL_ARRAY;
    }

    SymbolEntry *entry = create_symbol(node->value, sym_type, type, scope);
    
    if (sym_type == SYMBOL_ARRAY) {
        entry->array_size = atoi(node->children[1]->value);
    }

    if (!insert_symbol(entry)) {
        semantic_error("Variável já declarada neste escopo", line_num);
    }
}

void analyze_function_declaration(TreeNode *node, int scope) {
    if (!node) return;


    DataType return_type = (strcmp(node->children[0]->value, "int") == 0) ? TYPE_INT : TYPE_VOID;
    

    SymbolEntry *entry = create_symbol(node->value, SYMBOL_FUNCTION, return_type, scope);
    
    // Analisa params
    TreeNode *params = node->children[1];
    if (params && params->num_children > 0) {
        entry->param_types = (DataType*)malloc(sizeof(DataType) * params->num_children);
        entry->num_params = params->num_children;
        
        for (int i = 0; i < params->num_children; i++) {
            TreeNode *param = params->children[i];
            entry->param_types[i] = (strcmp(param->children[0]->value, "int") == 0) ? TYPE_INT : TYPE_VOID;
        }
    }

    if (!insert_symbol(entry)) {
        semantic_error("Função já declarada", line_num);
    }


    symbol_table->current_scope++;
    analyze_node(node->children[2], symbol_table->current_scope);
    symbol_table->current_scope--;
}

// Analisa expressoes
DataType analyze_expression(TreeNode *node, int scope) {
    if (!node) return TYPE_VOID;

    if (strcmp(node->node_type, "Num") == 0) {
        return TYPE_INT;
    }
    
    if (strcmp(node->node_type, "Variavel") == 0) {
        SymbolEntry *entry = lookup_symbol(node->value, scope);
        if (!entry) {
            semantic_error("Variável não declarada", line_num);
            return TYPE_VOID;
        }
        return entry->data_type;
    }

    if (strcmp(node->node_type, "Function-Call") == 0) {
        SymbolEntry *entry = lookup_symbol(node->value, scope);
        if (!entry || entry->symbol_type != SYMBOL_FUNCTION) {
            semantic_error("Função não declarada", line_num);
            return TYPE_VOID;
        }
        
        TreeNode *args = node->children[0];
        if (args && entry->num_params != (args->num_children > 0 ? args->num_children : 0)) {
            semantic_error("Número incorreto de argumentos", line_num);
        }
        
        return entry->data_type;
    }

    if (node->num_children >= 2) {
        DataType left_type = analyze_expression(node->children[0], scope);
        DataType right_type = analyze_expression(node->children[1], scope);
        
        if (!is_type_compatible(left_type, right_type)) {
            semantic_error("Incompatibilidade de tipos na expressão", line_num);
            return TYPE_VOID;
        }
        
        return TYPE_INT;
    }

    return TYPE_INT;
}

// Funcao principal da analise semantica
void analyze_node(TreeNode *node, int scope) {
    if (!node) return;

    // Analisa node atual
    if (strcmp(node->node_type, "Var-declaracao") == 0) {
        analyze_var_declaration(node, scope);
    }
    else if (strcmp(node->node_type, "Fun-declaracao") == 0) {
        analyze_function_declaration(node, scope);
    }
    else if (strcmp(node->node_type, "Assign-Expression") == 0) {
        DataType left_type = analyze_expression(node->children[0], scope);
        DataType right_type = analyze_expression(node->children[1], scope);
        
        if (!is_type_compatible(left_type, right_type)) {
            semantic_error("Incompatibilidade de tipos na atribuição", line_num);
        }
    }
    else if (strcmp(node->node_type, "Return-Statement") == 0) {
        //Verificar se o tipo de retorno corresponde à declaração da função
    }

    // Analisa recursivamente os filhos
    for (int i = 0; i < node->num_children; i++) {
        analyze_node(node->children[i], scope);
    }
}

void start_semantic_analysis(TreeNode *root) {
    symbol_table = init_symbol_table();
    add_built_in_functions(symbol_table);
    analyze_node(root, 0);
}

void print_symbol_table() {
    printf("\nTabela de símbolos:\n");
    printf("%-20s %-12s %-10s %-8s\n", "Nome", "Tipo", "Tipo de dado", "Escopo");
    printf("----------------------------------------\n");
    
    SymbolEntry *current = symbol_table->entries;
    while (current != NULL) {
        const char *sym_type = 
            current->symbol_type == SYMBOL_VARIABLE ? "Variável" :
            current->symbol_type == SYMBOL_ARRAY ? "Lista" : "Função";
        
        const char *data_type = 
            current->data_type == TYPE_INT ? "int" : "void";
        
        printf("%-20s %-12s %-10s %-8d\n", 
               current->name, sym_type, data_type, current->scope_level);
        
        current = current->next;
    }
}

void execute_semantic_analysis(TreeNode *root) {
    if (root != NULL) {
        start_semantic_analysis(root);
        print_symbol_table();
    }
    print_tree(root, 0);
}