#include <stdio.h>

struct node {

  int index;

  struct node *left;
  
  struct node *right;

};


struct node *create_tree(int index, struct node *left, struct node *right)
{
  struct node *node;

  node = (struct node *)malloc(sizeof(*node));

  node->index = index;

  node->left = left;

  node->right = right;

  return node;
}


void rec_print(struct node *tree)
{
  if (tree == NULL)
    return;

  rec_print(tree->left);

  rec_print(tree->right);

  printf("%d ", tree->index);
}


void iter_print(struct node *tree)
{
  struct elem *stack;
  int errcode = 0;

  stack = create_list(&errcode);
  add_elem(stack, tree, &errcode);

  while (!empty(stack)) {
    struct node *stack_elem;

    stack_elem = (struct node*)remove_elem(stack, &errcode);

    printf("%d", stack_elem->index);

    if (stack_elem->right)
      add_elem(stack, stack_elem->right, &errcode);

    if (stack_elem->left)
      add_elem(stack, stack_elem->left, &errcode);

  }
}


int main(int argc, char *argv[])
{
  struct node *tree;

  tree = create_tree(1, 
                     create_tree(2, 
                                 create_tree(3,
                                             NULL,
                                             NULL),
                                 NULL),
                     create_tree(4,
                                 NULL,
                                 NULL)
                     );

  iter_print(tree);
}
