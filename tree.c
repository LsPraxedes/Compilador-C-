#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

TreeNode* new_node(char *node_type, char *value) {
    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));
    node->node_type = strdup(node_type);
    node->value = value ? strdup(value) : NULL;
    node->num_children = 0;
    return node;
}

void add_child(TreeNode *parent, TreeNode *child) {
    if (child && parent->num_children < 10) {
        parent->children[parent->num_children++] = child;
    }
}

void print_tree(TreeNode *node, int depth) {
    if (node == NULL) return;
    
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    printf("%s", node->node_type);
    if (node->value) {
        printf(" (%s)", node->value);
    }
    printf("\n");
    
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], depth + 1);
    }
}

// Definição da variável global root
TreeNode *root = NULL;