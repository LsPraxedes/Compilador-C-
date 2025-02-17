#ifndef TREE_H
#define TREE_H

// Estrutura do nó da árvore
typedef struct TreeNode {
    char *node_type;
    char *value;
    int num_children;
    struct TreeNode *children[10];  
} TreeNode;

// Funções para manipulação da árvore
TreeNode* new_node(char *node_type, char *value);
void add_child(TreeNode *parent, TreeNode *child);
void print_tree(TreeNode *node, int depth);

// Variável global para a raiz da árvore
extern TreeNode *root;

#endif // TREE_H