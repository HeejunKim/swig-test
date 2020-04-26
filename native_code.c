/* File : native_code.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include "native_code.h"


struct test_client {
  char* test_string;
  char* test_lang;
};

func_pt_int global_pt = NULL;
func_ptr_struct_test_t* global_func_struct = NULL;

test_client_t* test_client_create(const char* test_string, const char* test_lang, test_info_t* info, test_type_t type) {
  test_client_t* self;
  self = calloc(1, sizeof(test_client_t));
  if (self == NULL) {
    return NULL;
  }

  if (test_string == NULL) {
    printf("error test_string null");
    return NULL;
  }
  self->test_string = malloc(strlen(test_string)+1);
  strncpy(self->test_string, test_string, strlen(test_string)+1);

  if (test_lang == NULL) {
    printf("error test_lang null");
    return NULL;
  }
  self->test_lang = malloc(strlen(test_lang)+1);
  strncpy(self->test_lang, test_lang, strlen(test_lang)+1);

  printf("info office_name : %s\n", info->office_name);
  printf("info building_name : %s\n", info->building_name);
  printf("info persion_name : %s\n", info->persion_name);
  printf("test type : %d\n", type);

  return self;
}

void test_client_destory(test_client_t *ctx) {
  if (ctx->test_string) {
    free(ctx->test_string);
  }

  if (ctx->test_lang) {
    free(ctx->test_lang);
  }

  if (ctx != NULL) {
    free(ctx);
  }
}

const char* get_test_string(test_client_t* ctx) {
  if (ctx == NULL) {
    return NULL;
  }

  return ctx->test_string;
}

const char* get_test_lang(test_client_t* ctx) {
  if (ctx == NULL) {
    return NULL;
  }

  return ctx->test_lang;
}

/*
 * default
 */

/* Compute factorial of n */
int fact(int n) {
  if (n <= 1)
    return 1;
  else
    return n*fact(n-1);
}

/* Compute n mod m */
int my_mod(int n, int m) {
  return(n % m);
}

/*
 * array
 */

/* copy the contents of the first array to the second */
void my_array_copy(int* sourceArray, int* targetArray, int nitems) {
  int i;
  for (i = 0; i < nitems; i++) {
    targetArray[i] = sourceArray[i];
  }
}

/* swap the contents of the two arrays */
void my_array_swap(int* array1, int* array2, int nitems) {
  int i, temp;
  for (i = 0; i < nitems; i++) {
    temp = array1[i];
    array1[i] = array2[i];
    array2[i] = temp;
  }
}

void test_exec(char* str, func_pt p) {
  p(str);
}

void *thread_fun(void *vargp) {
  printf("C Sleep 3 sec.....\n");
  sleep(3);
  int result = global_pt("Thread callback arg1", "Thread callback arg2", "UserData");
  printf("func_pt_int result = %d\n", result);
  return NULL;
}

void setCallback(func_pt_int p) {
  global_pt = p;
  pthread_t thread_id;
  pthread_create(&thread_id, NULL, thread_fun, NULL);
  pthread_join(thread_id, NULL);
}

void regist_func_ptr_struct(func_ptr_struct_test_t* struct_func_ptr){
  global_func_struct = struct_func_ptr;
}

void call_struct_func1() {
  int result = global_func_struct->func_1("Call Struct Function 1");
  printf("native code call function 1 result = %d\n", result);
}

void call_struct_func2() {
  int result = global_func_struct->func_2(365);
  printf("native code call function 2 result = %d\n", result);
}

void call_struct_func3() {
  char stringData[] = {'H', 'e', 'l', 'l', 'o', 0};
  //char* stringData = "Hello Wordl!!";
  global_func_struct->func_3(stringData);
  printf("native code call function 3\n");
}

void call_struct_get_func_data() {
  char result_data[5];
  printf("[%s] result_data ptr = %p\n", __FUNCTION__, result_data);
  bool result = global_func_struct->get_func_data(result_data, sizeof(result_data)-1);
  if (result == true) {
    printf("native code call get func data = %s\n", result_data);
  } else {
    printf("failed native code call get func data!!!!\n");
  }
}

// void* get_struct_func_user_data() {
//   return global_func_struct->user_data;
// }

void regist_and_call_func_ptrs(func_ptr_test_t* func_ptrs) {
  func_ptrs->set_func_ptr_struct_test(global_func_struct, (void*)"232324");
}
