/* native_code.i */

%module(directors="1") NativeCode
%{
  #include <native_code.h>
%}

// ISO C99 types
%include stdint.i

// typemap
%include typemaps.i


// void* <---> global::System.IntPtr
%typemap(ctype)  void * "void *"
%typemap(imtype) void * "global::System.IntPtr"
%typemap(cstype) void * "global::System.IntPtr"
%typemap(csin)   void * "$csinput"
%typemap(in)     void * %{ $1 = $input; %}
%typemap(out)    void * %{ $result = $1; %}
%typemap(csout)  void * { return $imcall; }

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

%insert(runtime) %{
  typedef void (SWIGSTDCALL *func_pt)(char* str);
  typedef int (SWIGSTDCALL *func_pt_int)(const char* arg1, const char* arg2, void* user_data);
%}

%cs_callback(func_pt, FuncPtCallback);
%cs_callback(func_pt_int, FuncPtIntCallback);

%pragma(csharp) moduleimports=%{
    public delegate void FuncPtCallback(string str);
    public delegate int FuncPtIntCallback(string arg1, string arg2, global::System.IntPtr userData);
%}

// struct + function pointer
%rename(FuncPtrStructTest) func_ptr_struct_test_t;
%nodefaultctor func_ptr_struct_test;
%nodefaultdtor func_ptr_struct_test;
%ignore func_1;
%ignore func_2;
%ignore func_3;
%ignore user_data;

%inline {
  typedef int (*wrapper_func_1)(void* arg);
  typedef int (*wrapper_func_2)(int arg);
  typedef void (*wrapper_func_3)(void* arg);
}

%extend func_ptr_struct_test {
    func_ptr_struct_test() {
      func_ptr_struct_test_t *ptr;
      ptr = (func_ptr_struct_test_t*)malloc(sizeof(func_ptr_struct_test_t));
      return ptr;
    }

    void SetFunc1Callback(wrapper_func_1 callback) {
      $self->func_1 = callback;
    }

    void SetFunc2Callback(wrapper_func_2 callback) {
      $self->func_2 = callback;
    }

    void SetFunc3Callback(wrapper_func_3 callback) {
      $self->func_3 = callback;
    }

    void SetUserDate(void* data) {
      $self->user_data = data;
    }

    ~func_ptr_struct_test() {
      free($self);
    }
};

%cs_callback(wrapper_func_1, FuncPtrStructTest.Func1Callback);
%cs_callback(wrapper_func_2, FuncPtrStructTest.Func2Callback);
%cs_callback(wrapper_func_3, FuncPtrStructTest.Func3Callback);

%typemap(cscode) func_ptr_struct_test %{
  public delegate int Func1Callback(global::System.IntPtr arg);
  public delegate int Func2Callback(int arg);
  public delegate void Func3Callback(global::System.IntPtr arg);
%}

%rename("%(camelcase)s") "";

%include "native_code.h"
