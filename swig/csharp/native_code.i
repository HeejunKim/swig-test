/* native_code.i */

%module(directors="1") NativeCode
%runtime %{
  #include <native_code.h>

  typedef void (SWIGSTDCALL *func_pt)(char* str);
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

// constants
%constant double PI = 3.14159;

// function pointer
%define %cs_callback(TYPE, CSTYPE)
        %typemap(ctype) TYPE, TYPE& "void*"
        %typemap(in) TYPE  %{ $1 = (TYPE)$input; %}
        %typemap(in) TYPE& %{ $1 = (TYPE*)&$input; %}
        %typemap(imtype, out="IntPtr") TYPE, TYPE& "CSTYPE"
        %typemap(cstype, out="IntPtr") TYPE, TYPE& "CSTYPE"
        %typemap(csin) TYPE, TYPE& "$csinput"
%enddef
%define %cs_callback2(TYPE, CTYPE, CSTYPE)
        %typemap(ctype) TYPE "CTYPE"
        %typemap(in) TYPE %{ $1 = (TYPE)$input; %}
        %typemap(imtype, out="IntPtr") TYPE "CSTYPE"
        %typemap(cstype, out="IntPtr") TYPE "CSTYPE"
        %typemap(csin) TYPE "$csinput"
%enddef

%ignore func_pt;

%cs_callback(func_pt, FuncPtCallback);

%pragma(csharp) moduleimports=%{
  public delegate void FuncPtCallback(string str);
%}

%rename("%(camelcase)s") "";

%include "native_code.h"
