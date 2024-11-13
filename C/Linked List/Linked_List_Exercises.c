#include <stddef.h> 
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


//.header
struct list_node
{
    struct list_node *next; 
};
 struct string_item
 {
    struct list_node node;
    const char *string;
 };

struct string_item *string_item_new(const char *string);
struct list_node *list_get_tail(struct list_node **head);
struct list_node *list_append(struct list_node **head, struct list_node *item);
struct list_node *list_pop(struct list_node **head);
//My methods
void list_free(struct list_node **head); //Unuseless, just for undestand how scroll the list.
void string_item_free(struct string_item **head); 
void string_remove_item(struct string_item **head, const char *string);


//.c
 int main()
 {
    //Create linked list
    struct string_item *my_linked_list = NULL;

    //Add node
    list_append((struct list_node **)&my_linked_list, (struct list_node *)string_item_new("Hello World"));
    list_append((struct list_node **)&my_linked_list, (struct list_node *)string_item_new("Test001"));
    list_append((struct list_node **)&my_linked_list, (struct list_node *)string_item_new("Test002"));
    list_append((struct list_node **)&my_linked_list, (struct list_node *)string_item_new("Last Item of the Linked List"));


    //Print
    struct string_item *string_item = my_linked_list;
    while (string_item)
    {
        printf("%s\n", string_item->string);
        string_item = (struct string_item *)string_item->node.next;
    }

    string_remove_item(&my_linked_list, "Test001");

    



    //Free
    string_item_free(&my_linked_list);
    return 0;
 }

#pragma region Start
 struct string_item *string_item_new(const char *string)
 {
    struct string_item *item = malloc(sizeof(struct string_item));
    if (!item)
    {
        return NULL;
    }
    item->string = string;
    return item;
 }

struct list_node *list_get_tail(struct list_node **head) {
    struct list_node *current_node = *head;
    struct list_node *last_node = NULL;
    while (current_node) {
        last_node = current_node;
        current_node = current_node->next;
    }
    return last_node;
}

struct list_node *list_append(struct list_node **head, struct list_node *item) {
    struct list_node *tail = list_get_tail(head);
    if (!tail) {
        *head = item;
    } else {
        tail->next = item;
    }
    item->next = NULL;
    return item;
}

struct list_node *list_pop(struct list_node **head) {
    struct list_node *current_head = *head;
    if (!current_head) {
        return NULL;
    }
    *head = (*head)->next;
    current_head->next = NULL;
    return current_head;
}
#pragma endregion

#pragma region My Methods
void list_free(struct list_node **head) {
    struct list_node *current = *head;
    struct list_node *next = NULL;
    while(current){
        next = current->next;
        free(current); //There's no memory allocated in the heap  
        current = next;
    }
    *head = NULL;
};

void string_item_free(struct string_item **head){
    struct string_item *current = *head;
    struct string_item *next = NULL;

    while (current)
    {
        next = (struct string_item *)current->node.next;
        free(current);
        current = next;
    }
    *head = NULL;
}

void string_remove_item(struct string_item **head, const char *string){
    struct string_item *current = *head;
    struct string_item *prev = NULL;

    while (current)
    {   
        if(strcmp(current->string, string) == 0) //Not current->string == string! this compare the adress not the value!!
        {
            if (prev) {
                prev->node.next = current->node.next;//prev->next jump to +1
            } else {
                *head = (struct string_item*)current->node.next;//in the head of the list!
            }
            current->node.next = NULL;
            free(current);//remove
            return;
        }
        prev = current;
        current = (struct string_item*)current->node.next;
    }
    //There's no match!
    printf("string not found\n");
    
}
#pragma endregion
