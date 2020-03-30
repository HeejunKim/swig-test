
/* File : native_code.h */

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

// default
int fact(int n);
int my_mod(int n, int m);

// array
void my_array_copy(int* source_array, int* target_array, int nitems);
void my_array_swap(int* array1, int* array2, int nitems);

#ifdef __cplusplus
}
#endif
