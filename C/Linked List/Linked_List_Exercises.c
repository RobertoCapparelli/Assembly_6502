#include <stddef.h> 
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#pragma region DEFINE
#define APPEND_NODE(head, item) list_append((struct list_node **)(head), (struct list_node *)(item))
#define APPEND_DOUBLY_NODE(head, str) doubly_append((head), doubly_list_node_new((str)))
#define LOG_INFO(msg) printf("Info: %s\n", msg)
#define PRINT_LIST(list, node_type, string_field, next_field)          \
{                                                                      \
    node_type *current = list;                                         \
    while (current)                                                    \
    {                                                                  \
        printf("%s\n", current->string_field);                         \
        current = (node_type *)current->next_field;                    \
    }                                                                  \
}
#pragma endregion

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

struct doubly_list_node
{
    struct doubly_list_node *prev;
    struct doubly_list_node *next;
    const char *string;
    
};

#pragma region declaration
// declaration for string_item end list_node
struct string_item *string_item_new(const char *string);
struct list_node *list_get_tail(struct list_node **head);
struct list_node *list_append(struct list_node **head, struct list_node *item);
struct list_node *list_pop(struct list_node **head);
void list_free(struct list_node **head);
void string_item_free(struct string_item **head);
void string_remove_item(struct string_item **head, const char *string);
void string_reverse_list(struct string_item **head);

// declaration for doubly_list_node
struct doubly_list_node *doubly_list_node_new(const char *string);
struct doubly_list_node *doubly_list_get_tail(struct doubly_list_node **head);
struct doubly_list_node *doubly_append(struct doubly_list_node **head, struct doubly_list_node *item);
void doubly_list_free(struct doubly_list_node **head);
void doubly_list_remove_item(struct doubly_list_node **head, const char *string);
void doubly_list_insert_item(struct doubly_list_node **head, const char *stringToAdd, const char *stringItemToReference, int before);

#pragma endregion

//.c

 int main()
 {
    #pragma region Simple_List_Node
    //Create linked list
    struct string_item *my_linked_list = NULL;

    //Add node
    APPEND_NODE(&my_linked_list, string_item_new("Hello World"));
    APPEND_NODE(&my_linked_list, string_item_new("Test001"));
    APPEND_NODE(&my_linked_list, string_item_new("Test002"));
    APPEND_NODE(&my_linked_list, string_item_new("Last Item of the Linked List"));

    //Start
    LOG_INFO("StartingList");
    PRINT_LIST(my_linked_list, struct string_item, string, node.next);

    //Remove Test001
    LOG_INFO("Remove Item");
    string_remove_item(&my_linked_list, "Test001");
    PRINT_LIST(my_linked_list, struct string_item, string, node.next);

    //Reverse
    string_reverse_list(&my_linked_list);
    LOG_INFO("REVERSE");
    PRINT_LIST(my_linked_list, struct string_item, string, node.next);
 
    //Free
    string_item_free(&my_linked_list);
    #pragma endregion

    LOG_INFO("START WITH DOUBLY LINKED LIST \n\n");

    #pragma region Doubly_Linked_List
    //create doubly linked list
    struct doubly_list_node *my_doubly_list = NULL;
    APPEND_DOUBLY_NODE(&my_doubly_list, "Hello Doubly List");
    APPEND_DOUBLY_NODE(&my_doubly_list, "Node 1");
    APPEND_DOUBLY_NODE(&my_doubly_list, "Node 2");
    APPEND_DOUBLY_NODE(&my_doubly_list, "Last Node");

    //Start
    LOG_INFO("Doubly List:");
    PRINT_LIST(my_doubly_list, struct doubly_list_node, string, next);

    //Insert before
    LOG_INFO("Insert 'Before Node 2':");
    doubly_list_insert_item(&my_doubly_list, "Inserted Before Node 2", "Node 2", 1);
    PRINT_LIST(my_doubly_list, struct doubly_list_node, string, next);

    //Insert after
    LOG_INFO("Insert 'After Last Node':");
    doubly_list_insert_item(&my_doubly_list, "Inserted After Last Node", "Last Node", 0);
    PRINT_LIST(my_doubly_list, struct doubly_list_node, string, next);

    //Remove
    LOG_INFO("Remove Node 1:");
    doubly_list_remove_item(&my_doubly_list, "Node 1");
    PRINT_LIST(my_doubly_list, struct doubly_list_node, string, next);

    //Free
    doubly_list_free(&my_doubly_list);
    #pragma endregion

    return 0;
 }

#pragma region Methods_From_PDF
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

 struct doubly_list_node *doubly_list_node_new(const char *string) {
    struct doubly_list_node *item = malloc(sizeof(struct doubly_list_node));
    if (!item) {
        return NULL;
    }
    item->string = string;
    item->prev = NULL;    
    item->next = NULL;
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
struct doubly_list_node *doubly_list_get_tail(struct doubly_list_node **head) {
    struct doubly_list_node *current_node = *head;
    struct doubly_list_node *last_node = NULL;
    while (current_node) {
        last_node = current_node;
        current_node = current_node->next;
    }
    return last_node;
}
struct doubly_list_node *doubly_append(struct doubly_list_node **head, struct doubly_list_node *item)
{
    struct doubly_list_node *tail = doubly_list_get_tail(head);
    if(!tail)
    {
        *head = item;
    }
    else
    {
        tail->next = item;
    }

    item->prev = tail;
    item->next = NULL;
    return item;
}

#pragma endregion


#pragma region My_Methods

#pragma region Free_Methods
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
void doubly_list_free(struct doubly_list_node **head) {
    struct doubly_list_node *current = *head;
    struct doubly_list_node *next = NULL;

    while (current) {
        next = current->next; 
        free(current);        
        current = next;      
    }

    *head = NULL; 
}
#pragma endregion

#pragma region Remove_Item
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

void doubly_list_remove_item(struct doubly_list_node **head, const char *string) {
    struct doubly_list_node *current = *head;

    while (current) {
        if (strcmp(current->string, string) == 0) { 
            
            if (current->prev) {
                current->prev->next = current->next;
            } else {
                *head = current->next; 
            }
            if (current->next) {
                current->next->prev = current->prev;
            }
            free(current); 
            return;
        }
        current = current->next; 
    }

    printf("String '%s' not found\n", string);
}
#pragma endregion

void doubly_list_insert_item(struct doubly_list_node **head, const char *stringToAdd, const char *stringItemToReference, int before)
{
    struct doubly_list_node *current = *head;
    while(current)
    {
        if(strcmp(current->string, stringItemToReference) == 0) //If Match
        {
            struct doubly_list_node *new_node = doubly_list_node_new(stringToAdd); //New node

            if (before) 
            {
                new_node->prev = current->prev; //Set the link
                new_node->next = current;
                if (current->prev) 
                {
                    current->prev->next = new_node; //if there's a prev
                } 
                else 
                {
                    *head = new_node; //If there isn't a head, newNode is the new head
                }
                current->prev = new_node;
            }
            else
            {
                new_node->next = current->next;
                new_node->prev = current;
                if (current->next) //current->next is still the old one, so if there's a next one assign the prev pointer
                { 
                    current->next->prev = new_node;
                }

                current->next = new_node; //Set NewNode to the next one (current)
            }
            return; 
        }

        current = current->next; //next iteration
    }
}

void string_reverse_list(struct string_item **head)
{
    struct string_item *current = *head;
    struct string_item *prev = NULL;
    struct string_item *next = NULL;

    while (current !=NULL)
    {
        next = current->node.next;
        current->node.next = prev; //Reversing the link, at the first one the next is NULL becouse the last item point to NULL
        prev = current; 
        current = next; //next iteration
    }
    *head = prev; //at the end prev point to the last item, so while we making the reverse of the list the head have to point to the last item(new first item)
}


#pragma endregion
