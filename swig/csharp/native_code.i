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

%csmethodmodifiers myArrayCopyUsingFixedArrays "public unsafe";
%csmethodmodifiers myArraySwapUsingFixedArrays "public unsafe";
%csmethodmodifiers my_array_copy "public unsafe";
%csmethodmodifiers my_array_swap "public unsafe";

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
%ignore get_func_data;
%ignore user_data;

%csmethodmodifiers SetFunc1Callback "private"
%csmethodmodifiers GetFunc1Callback "private"
%csmethodmodifiers SetFunc2Callback "private"
%csmethodmodifiers GetFunc2Callback "private"
%csmethodmodifiers _setFunc3Callback "private"
%csmethodmodifiers _getFunc3Callback "private"
%csmethodmodifiers _setGetFuncDataCallback "private"
%csmethodmodifiers _getGetFuncDataCallback "private"
%csmethodmodifiers SetUserDate "private"
%csmethodmodifiers GetUserData "private"

%extend func_ptr_struct_test {
    func_ptr_struct_test() {
      func_ptr_struct_test_t *ptr;
      ptr = (func_ptr_struct_test_t*)malloc(sizeof(func_ptr_struct_test_t));
      return ptr;
    }

    void SetFunc1Callback(void* callback) {
      $self->func_1 = (int(*)(void*))callback;
    }

    void* GetFunc1Callback() {
      return (void*)$self->func_1;
    }

    void SetFunc2Callback(void* callback) {
      $self->func_2 = (int(*)(int))callback;
    }

    void* GetFunc2Callback() {
      return (void*)$self->func_2;
    }

    void _setFunc3Callback(void* callback) {
      $self->func_3 = (void(*)(char*))callback;
    }

    void* _getFunc3Callback() {
      return (void*)$self->func_3;
    }

    void _setGetFuncDataCallback(void* callback) {
      $self->get_func_data = (bool(*)(char*,int))callback;
    }

    void* _getGetFuncDataCallback() {
      return (void*)$self->get_func_data;
    }

    void SetUserData(void* data) {
      $self->user_data = data;
    }

    void* GetUserData() {
      return $self->user_data;
    }

    ~func_ptr_struct_test() {
      free($self);
    }
};

%cs_callback(wrapper_func_1, FuncPtrStructTest.Func1Callback);
%cs_callback(wrapper_func_2, FuncPtrStructTest.Func2Callback);
%cs_callback(wrapper_func_3, FuncPtrStructTest.WrapperFunc3Callback);
%cs_callback(wrapper_get_func_data, FuncPtrStructTest.WrapperGetFuncDataCallback);

%typemap(cscode) func_ptr_struct_test %{
  public delegate int Func1Callback(global::System.IntPtr arg);
  public delegate int Func2Callback(int arg);
  public delegate void Func3Callback(string arg);
  public delegate bool GetFuncDataCallback(out byte[] data, int size);

  public Func1Callback Func1
  {
    set {
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(value);
      SetFunc1Callback(callback);
    }
    get {
      global::System.IntPtr funcPtr = GetFunc1Callback();
      Func1Callback callback = (Func1Callback)System.Runtime.InteropServices.Marshal.GetDelegateForFunctionPointer(funcPtr, typeof(Func1Callback));
      return callback;
    }
  }

  public Func2Callback Func2
  {
    set {
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(value);
      SetFunc2Callback(callback);
    }
    get {
      global::System.IntPtr funcPtr = GetFunc2Callback();
      Func2Callback callback = (Func2Callback)System.Runtime.InteropServices.Marshal.GetDelegateForFunctionPointer(funcPtr, typeof(Func2Callback));
      return callback;
    }
  }

  public Func3Callback Func3
  {
    set {
      _func3Callback = value;
      WrapperFunc3Callback wrapperCallback = (str) => {
        string strData = (str != global::System.IntPtr.Zero ? System.Runtime.InteropServices.Marshal.PtrToStringAuto(str) : null);
        _func3Callback(strData);
      };
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(wrapperCallback);
      _setFunc3Callback(callback);
    }
    get {
      return _func3Callback;
    }
  }

  public GetFuncDataCallback GetFuncData
  {
    set {
      _getFuncDataCallback = value;
      WrapperGetFuncDataCallback wrapperCallback = (data, size) => {
        byte[] bufferData;
        bool result = _getFuncDataCallback(out bufferData, size);
        if(result) {
          System.Runtime.InteropServices.Marshal.Copy(bufferData, 0, data, bufferData.Length);
        }
        return result;
      };
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(wrapperCallback);
      _setGetFuncDataCallback(callback);
    }
    get {
      return _getFuncDataCallback;
    }
  }

  public global::System.IntPtr UserData
  {
    set {
      SetUserData(value);
    }
    get {
      return GetUserData();
    }
  }

  private Func3Callback _func3Callback;
  private GetFuncDataCallback _getFuncDataCallback;

  public delegate void WrapperFunc3Callback(global::System.IntPtr str);
  public delegate bool WrapperGetFuncDataCallback(global::System.IntPtr data, int size);
%}

%rename(FuncPtrTest) func_ptr_test_t;
%ignore set_func_ptr_struct_test;

%inline {
  typedef void (*wrapper_set_func_ptr_struct_test)(func_ptr_struct_test_t* func_callback, void* user_data); 
}

%extend func_ptr_test {
  void SetFuncPtrTest(wrapper_set_func_ptr_struct_test callback) {
    $self->set_func_ptr_struct_test = callback;
  }

  void SetUserData(void* data) {
    $self->user_data = data;
  }
}

%cs_callback(wrapper_set_func_ptr_struct_test, FuncPtrTest.SetFuncPtrStructTest);

%typemap(cscode) func_ptr_test %{
  public delegate void SetFuncPtrStructTest(FuncPtrStructTest funcCallback, global::System.IntPtr userData);
%}


%rename("%(camelcase)s") "";

%include "native_code.h"
