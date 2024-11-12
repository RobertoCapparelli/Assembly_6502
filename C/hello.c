    int main(int argc, char **argv)
    {
        return argc;
    }


    void ptrofptr()
 {
    const char *string0 = "Hello";
    const char *string1 = " ";
    const char *string2 = "World";
    const char *strings[3];
    strings[0] = string0;
    strings[1] = string1;
    strings[2] = string2;
    const char **strings_ptr = strings;
    for (int i = 0; i < 3; i++)
    {
        const char *string = strings_ptr[i];
    }
 }