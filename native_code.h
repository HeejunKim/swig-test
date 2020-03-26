
/* File : native_code.h */

#ifdef __cplusplus
extern "C" {
#endif

// enum
typedef enum test_type {
    TEST_TYPE_OK,
    TEST_TYPE_NG,
    TEST_TYPE_NONE
} test_type_t;

// struct
typedef struct test_client test_client_t;
test_client_t* test_client_create(const char* test_string, const char* test_lang);
void test_client_destory(test_client_t *ctx);
const char* get_test_string(test_client_t* ctx);
const char* get_test_lang(test_client_t* ctx);

// default
int fact(int n);
int my_mod(int n, int m);

// array
void my_array_copy(int* source_array, int* target_array, int nitems);
void my_array_swap(int* array1, int* array2, int nitems);

#ifdef __cplusplus
}
#endif
