/* File : native_code.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "native_code.h"


struct test_client {
  char* test_string;
  char* test_lang;
};

test_client_t* test_client_create(const char* test_string, const char* test_lang, test_info_t* info) {
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
