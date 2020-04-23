
/* File : native_code.h */

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// enum
typedef enum test_type {
    TEST_TYPE_OK = 100,
    TEST_TYPE_NG = 200,
    TEST_TYPE_NONE = 0
} test_type_t;

// struct
typedef struct test_info {
    char* office_name;
    char* building_name;
    char* persion_name;
} test_info_t;

typedef struct test_client test_client_t;
test_client_t* test_client_create(const char* test_string, const char* test_lang, test_info_t* info, test_type_t type);
void test_client_destory(test_client_t *ctx);
const char* get_test_string(test_client_t* ctx);
const char* get_test_lang(test_client_t* ctx);

// func ptr
typedef void (*func_pt)(char* str);
typedef int (*func_pt_int)(const char* arg1, const char* arg2, void* user_data);
void test_exec(char* str, func_pt p);
void setCallback(func_pt_int p);

// default
int fact(int n);
int my_mod(int n, int m);

// array
void my_array_copy(int* source_array, int* target_array, int nitems);
void my_array_swap(int* array1, int* array2, int nitems);


// struct + function pointer
typedef struct func_ptr_struct_test {
    int (*func_1)(void* arg);
    int (*func_2)(int arg);
    void (*func_3)(char* str);
    bool (*get_func_data)(char* data, int size);
    void* user_data;
} func_ptr_struct_test_t;

void regist_func_ptr_struct(func_ptr_struct_test_t* struct_func_ptr);
void call_struct_func1();
void call_struct_func2();
void call_struct_func3();
void call_struct_get_func_data();
void* get_struct_func_user_data();

#ifdef __cplusplus
}
#endif
