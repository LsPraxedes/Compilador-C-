/***********************************************/
/* Implementação de árvore sintática abstrata  */
/* Utilizada pelo compilador para representar  */
/* a estrutura do programa após a análise      */
/***********************************************/

#include <stdio.h>        
#include <stdlib.h>       
#include <string.h>       
#include "tree.h"         

/*
 * Cria um novo nó da árvore sintática.
 *
 * Parâmetros:
 *   node_type: String que representa o tipo do nó (ex: "Var-declaracao", "Expression", etc.)
 *   value: Valor associado ao nó, pode ser NULL se não houver valor específico
 *
 * Retorna:
 *   Ponteiro para o novo nó criado
 */
TreeNode* new_node(char *node_type, char *value) {

    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));    
    node->node_type = strdup(node_type);
    node->value = value ? strdup(value) : NULL;
    
    node->num_children = 0;
    
    return node;
}

/*

 * Adiciona um nó filho a um nó pai na árvore.
 *
 * Parâmetros:
 *   parent: Nó pai ao qual o filho será adicionado
 *   child: Nó filho a ser adicionado
 * 
 */
void add_child(TreeNode *parent, TreeNode *child) {
    /* Verifica se o filho existe e se há espaço disponível no array de filhos */
    if (child && parent->num_children < 10) {
        /* Adiciona o filho na próxima posição disponível */
        parent->children[parent->num_children++] = child;
    }
}

/**
 * 
 * Imprime a árvore sintática recursivamente, mostrando a estrutura hierárquica.
 *
 * Parâmetros:
 *   node: Nó atual a ser impresso
 *   depth: Profundidade atual na árvore (usado para identação)
 *
 */
void print_tree(TreeNode *node, int depth) {
    /* Caso base: retorna se o nó for NULL */
    if (node == NULL) return;
    
    /* Imprime a identação baseada na profundidade */
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    printf("%s", node->node_type);
    
    if (node->value) {
        printf(" (%s)", node->value);
    }
    printf("\n");
    
    /* Chama recursivamente para cada filho */
    for (int i = 0; i < node->num_children; i++) {
        print_tree(node->children[i], depth + 1);
    }
}

TreeNode *root = NULL;