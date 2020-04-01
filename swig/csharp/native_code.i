/* native_code.i */

%module NativeCode
%{
  #include <native_code.h>
%}

// ISO C99 types
%include stdint.i

// typemap
%include typemaps.i

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
  test_client(const char* test_string, const char* test_lang, test_info_t* info, test_type_t type) {
    return test_client_create(test_string, test_lang, info, type);
  }

  ~test_client() {
    test_client_destory($self);
  }
}

%rename("%(camelcase)s") "";

// %define %cs_callback(TYPE, CSTYPE)
//     %typemap(ctype) TYPE, TYPE& "void*"
//     %typemap(in) TYPE  %{ $1 = ($1_type)$input; %}
//     %typemap(in) TYPE& %{ $1 = ($1_type)&$input; %}
//     %typemap(imtype, out="IntPtr") TYPE, TYPE& "CSTYPE"
//     %typemap(cstype, out="IntPtr") TYPE, TYPE& "CSTYPE"
//     %typemap(csin) TYPE, TYPE& "$csinput"
// %enddef

// %cs_callback(func_pt, FuncPtCallback)
%typemap(cscode) func_pt %{
    public delegate void FuncPtCallback(string str);
%}

%constant double PI = 3.14159;

%include "native_code.h"
