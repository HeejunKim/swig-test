/* native_code.i */

%module NativeCode
%{
#include <native_code.h>
%}

// type
%inline %{
typedef signed char               int8_t;
typedef short int                 int16_t;
typedef int                       int32_t;
typedef unsigned char             uint8_t;
typedef unsigned short int        uint16_t;
typedef unsigned int              uint32_t;
typedef long int                  _time_t;
%}

// array
%include arrays_csharp.i

%apply int INPUT[]  { int* source_array }
%apply int OUTPUT[] { int* target_array }

%apply int INOUT[] { int* array1 }
%apply int INOUT[] { int* array2 }

%clear int* source_array;
%clear int* target_array;

%clear int* array1;
%clear int* array2;

%csmethodmodifiers "public unsafe";

%apply int FIXED[] { int* source_array }
%apply int FIXED[] { int* target_array }

%inline %{
void myArrayCopyUsingFixedArrays(int* source_array, int* target_array, int nitems) {
  my_array_copy(source_array, target_array, nitems);
}
%}

%apply int FIXED[] { int* array1 }
%apply int FIXED[] { int* array2 }

%inline %{
void myArraySwapUsingFixedArrays(int* array1, int* array2, int nitems) {
  my_array_swap(array1, array2, nitems);
}
%}

// enum
%rename(TestType) test_type_t;

// struct
%rename(TextClient) test_client;
%nodefaultctor test_client;
%nodefaultdtor test_client;
struct test_client {};

%ignore test_client_create;
%ignore test_client_destory;

%extend test_client {
  test_client(const char* test_string, const char* test_lang) {
    return test_client_create(test_string, test_lang);
  }

  ~test_client() {
    test_client_destory($self);
  }
}

%include "native_code.h"
