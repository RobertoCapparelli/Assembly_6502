#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct bullet
{
    float speed;
    float x;
    float y;
    float z;
    float dx;
    float dy;
    float dz;
    float lifetime;
} bullet_t;

typedef struct dynarray_of_bullets
{
    bullet_t *data;
    size_t length;
    size_t capacity;
} dynarray_of_bullets_t;

static size_t malloc_counter = 0;
static size_t malloc_total_allocations = 0;

void *aiv_malloc(const size_t length)
{
    void *data = malloc(length);
    if (!data)
    {
        return NULL;
    }
    malloc_counter++;
    malloc_total_allocations += length;
    return data;
}

void aiv_free(void *data, const size_t amount)
{
    malloc_total_allocations -= amount;
    free(data);
}

int dynarray_of_bullets_set_capacity(dynarray_of_bullets_t *bullets, const size_t new_capacity)
{
    if (new_capacity < bullets->length)
    {
        return -1;
    }

    if (new_capacity == 0)
    {
        bullets->data = NULL;
        bullets->capacity = 0;
        return 0;
    }

     bullet_t *new_data = realloc(bullets->data, sizeof(bullet_t) * new_capacity);
    if (!new_data)
    {
        perror("realloc()");
        return -1;
    }
    
    bullets->data = new_data;
    bullets->capacity = new_capacity;
    return 0;
}

int dynarray_of_bullets_reserve(dynarray_of_bullets_t *bullets, const size_t elements)
{
    return dynarray_of_bullets_set_capacity(bullets, bullets->capacity + elements);
}

int dynarray_of_bullets_remove(dynarray_of_bullets_t *bullets, const size_t index)
{
    if (index >= bullets->length)
    {
        return -1;
    }

    if (bullets->length > 0 && index == bullets->length - 1)
    {
        bullets->length--;
        return 0;
    }

    memmove(&bullets->data[index], &bullets->data[index + 1], sizeof(bullet_t) * (bullets->length - index));
    bullets->length--;
    return 0;
}

int dynarray_of_bullets_insert(dynarray_of_bullets_t *bullets, const size_t index, const bullet_t *new_bullet);

int dynarray_of_bullets_append(dynarray_of_bullets_t *bullets, const bullet_t *new_bullet)
{
    return dynarray_of_bullets_insert(bullets, bullets->length, new_bullet);
}

int dynarray_of_bullets_init(dynarray_of_bullets_t *bullets, const size_t capacity)
{
    bullets->length = 0;
    if (dynarray_of_bullets_set_capacity(bullets, capacity))
    {
        return -1;
    }

    return 0;
}

int dynarray_of_bullets_empty(dynarray_of_bullets_t *bullets)
{
    bullets->length = 0;
    return 0;
}

int dynarray_of_bullets_insert(dynarray_of_bullets_t *bullets, const size_t index, const bullet_t *new_bullet)
{
    if (!new_bullet)
    {
        return -1;
    }

    if (bullets->length + 1 > bullets->capacity)
    {
        if (dynarray_of_bullets_reserve(bullets, 1))
        {
            return -1;
        }
    }

    if (index < bullets->length)
    {
        memmove(&bullets->data[index + 1], &bullets->data[index], sizeof(bullet_t) * (bullets->length - index));
    }
    memcpy(&bullets->data[index], new_bullet, sizeof(bullet_t));
    bullets->length++;
    return 0;
}

int main(int argc, char **argv)
{
    dynarray_of_bullets_t bullets;
    if (dynarray_of_bullets_init(&bullets, 10))
    {
        printf("unable to initialize dynarray!\n");
        return -1;
    }

    bullet_t bullet0;
    if (dynarray_of_bullets_append(&bullets, &bullet0))
    {
        printf("unable to append bullet at slot %llu!\n", bullets.length);
        return -1;
    }

    if (dynarray_of_bullets_append(&bullets, &bullet0))
    {
        printf("unable to append bullet at slot %llu!\n", bullets.length);
        return -1;
    }

    dynarray_of_bullets_reserve(&bullets, 1024);
    for (size_t i = 0; i < 1024; i++)
    {
        if (dynarray_of_bullets_append(&bullets, &bullet0))
        {
            printf("unable to append bullet at slot %llu!\n", bullets.length);
            return -1;
        }
    }

    printf("appended %llu elements with capacity %llu and %llu calls to malloc\n", bullets.length, bullets.capacity, malloc_counter);
    printf("sizeof(bullet_t) = %llu *** sizeof(bullet_t) * %llu = %llu\n", sizeof(bullet_t), bullets.length, sizeof(bullet_t) * bullets.length);
    printf("malloc total allocations: %llu\n", malloc_total_allocations);

    dynarray_of_bullets_remove(&bullets, 0);

    printf("appended %llu elements with capacity %llu and %llu calls to malloc\n", bullets.length, bullets.capacity, malloc_counter);
    printf("sizeof(bullet_t) = %llu *** sizeof(bullet_t) * %llu = %llu\n", sizeof(bullet_t), bullets.length, sizeof(bullet_t) * bullets.length);
    printf("malloc total allocations: %llu\n", malloc_total_allocations);

    dynarray_of_bullets_remove(&bullets, 1024);

    printf("appended %llu elements with capacity %llu and %llu calls to malloc\n", bullets.length, bullets.capacity, malloc_counter);
    printf("sizeof(bullet_t) = %llu *** sizeof(bullet_t) * %llu = %llu\n", sizeof(bullet_t), bullets.length, sizeof(bullet_t) * bullets.length);
    printf("malloc total allocations: %llu\n", malloc_total_allocations);

    dynarray_of_bullets_remove(&bullets, 100);

    printf("appended %llu elements with capacity %llu and %llu calls to malloc\n", bullets.length, bullets.capacity, malloc_counter);
    printf("sizeof(bullet_t) = %llu *** sizeof(bullet_t) * %llu = %llu\n", sizeof(bullet_t), bullets.length, sizeof(bullet_t) * bullets.length);
    printf("malloc total allocations: %llu\n", malloc_total_allocations);

    return 0;
}