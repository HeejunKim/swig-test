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
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate<Func1Callback>(value);
      SetFunc1Callback(callback);
    }
    get {
      global::System.IntPtr funcPtr = GetFunc1Callback();
      Func1Callback callback = System.Runtime.InteropServices.Marshal.GetDelegateForFunctionPointer<Func1Callback>(funcPtr);
      return callback;
    }
  }

  public Func2Callback Func2
  {
    set {
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate<Func2Callback>(value);
      SetFunc2Callback(callback);
    }
    get {
      global::System.IntPtr funcPtr = GetFunc2Callback();
      Func2Callback callback = System.Runtime.InteropServices.Marshal.GetDelegateForFunctionPointer<Func2Callback>(funcPtr);
      return callback;
    }
  }

  public Func3Callback Func3
  {
    set {
      long contextId = swigCPtr.Handle.ToInt64();
      _pendingFunc3Callbacks.Add(contextId, value);
      WrapperFunc3Callback wrapperCallback = (str) => {
        string strData = (str != global::System.IntPtr.Zero ? System.Runtime.InteropServices.Marshal.PtrToStringAuto(str) : null);
        value(strData);
      };
      global::System.IntPtr wrapperCallbackPtr = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate<WrapperFunc3Callback>(wrapperCallback);
      _setFunc3Callback(wrapperCallbackPtr);
    }
    get {
      long contextId = swigCPtr.Handle.ToInt64();
      if (_pendingFunc3Callbacks.ContainsKey(contextId)) {
        return _pendingFunc3Callbacks[contextId] as Func3Callback;
      } else {
        return null;
      }
    }
  }

  public GetFuncDataCallback GetFuncData
  {
    set {
      long contextId = swigCPtr.Handle.ToInt64();
      _pendingFuncDataCallbacks.Add(contextId, value);
      WrapperGetFuncDataCallback wrapperCallback = (data, size) => {
        byte[] bufferData;
        bool result = value(out bufferData, size);
        if(result) {
          System.Runtime.InteropServices.Marshal.Copy(bufferData, 0, data, bufferData.Length);
        }
        return result;
      };
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate<WrapperGetFuncDataCallback>(wrapperCallback);
      _setGetFuncDataCallback(callback);
    }
    get {
      long contextId = swigCPtr.Handle.ToInt64();
      if (_pendingFuncDataCallbacks.ContainsKey(contextId)) {
        return _pendingFuncDataCallbacks[contextId] as GetFuncDataCallback;
      } else {
        return null;
      }
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

  internal delegate void WrapperFunc3Callback(global::System.IntPtr str);
  internal delegate bool WrapperGetFuncDataCallback(global::System.IntPtr data, int size);

  private static System.Collections.Generic.Dictionary<long, System.Delegate> _pendingFunc3Callbacks = new System.Collections.Generic.Dictionary<long, System.Delegate>();
  private static System.Collections.Generic.Dictionary<long, System.Delegate> _pendingFuncDataCallbacks = new System.Collections.Generic.Dictionary<long, System.Delegate>();

  private void RemoveCallback()
  {
    System.Console.WriteLine("FuncPtrStructTest Dispose RemoveCallback");
    long contextId = swigCPtr.Handle.ToInt64();
    if(_pendingFunc3Callbacks.ContainsKey(contextId)) {
      System.Console.WriteLine("FuncPtrStructTest Dispose _pendingFunc3Callbacks RemoveCallback");
      _pendingFunc3Callbacks.Remove(contextId);
    }
    if(_pendingFuncDataCallbacks.ContainsKey(contextId)) {
      System.Console.WriteLine("FuncPtrStructTest Dispose _pendingFuncDataCallbacks RemoveCallback");
      _pendingFuncDataCallbacks.Remove(contextId);
    }
  }
%}

%typemap(csdispose) func_ptr_struct_test %{
  ~$csclassname() {
    RemoveCallback();
    Dispose(false);
  }

  public void Dispose() {
    RemoveCallback();
    Dispose(true);
    global::System.GC.SuppressFinalize(this);
  }
%}

%rename(FuncPtrTest) func_ptr_test_t;
%ignore set_func_ptr_struct_test;

%csmethodmodifiers SetFuncPtrTest "private"
%csmethodmodifiers GetFuncPtrTest "private"
%csmethodmodifiers SetUserData "private"
%csmethodmodifiers GetUserData "private"

%extend func_ptr_test {
  void SetFuncPtrTest(void* callback) {
    $self->set_func_ptr_struct_test = (void(*)(func_ptr_struct_test_t*, void*))callback;
  }

  void* GetFuncPtrTest() {
    return (void*)$self->set_func_ptr_struct_test;
  }

  void SetUserData(void* data) {
    $self->user_data = data;
  }

  void* GetUserData() {
    return $self->user_data;
  }
}

%cs_callback(wrapper_set_func_ptr_struct_test, FuncPtrTest.SetFuncPtrStructTestCallback);

%typemap(cscode) func_ptr_test %{
  public delegate void SetFuncPtrStructTestCallback(FuncPtrStructTest funcCallback, global::System.IntPtr userData);

  public SetFuncPtrStructTestCallback SetFuncPtrStructTest
  {
    set {
      _setFuncPtrStructTestCallback = value;
      WrapperSetFuncPtrStructTestCallback wrapperCallback = (funcCallback, userData) => {
        FuncPtrStructTest callbacks = (funcCallback != global::System.IntPtr.Zero ? new FuncPtrStructTest(funcCallback, false) : null);
        _setFuncPtrStructTestCallback(callbacks, userData);
      };
      global::System.IntPtr callback = System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate<WrapperSetFuncPtrStructTestCallback>(wrapperCallback);
      SetFuncPtrTest(callback);
    }
    get {
      return _setFuncPtrStructTestCallback;
    }
  }

  private SetFuncPtrStructTestCallback _setFuncPtrStructTestCallback; 
  public delegate void WrapperSetFuncPtrStructTestCallback(global::System.IntPtr funcCallback, global::System.IntPtr userData);
%}

// int arrsy struct test
%rename(IntArrayStructTest) int_array_struct_test;

%ignore test1;
%ignore test2;

%extend int_array_struct_test {
  void _setTest1(void* value) {
    $self->test1 = (int*)value;
  }

  void* _getTest1() {
    return (void*)$self->test1;
  }

  void _setTest2(void* value) {
    $self->test2 = (int*)value;
  }

  void* _getTest2() {
    return (void*)$self->test2;
  }
}

%typemap(cscode) int_array_struct_test %{
  public int[] Test1
  {
    set {
      test1Size = value.Length;
      global::System.IntPtr valuePtr = System.Runtime.InteropServices.Marshal.UnsafeAddrOfPinnedArrayElement(value, 0);
      _setTest1(valuePtr);
    }
    get {
      global::System.IntPtr valuePtr = _getTest1();
      int[] valueArray = new int[test1Size];
      global::System.Runtime.InteropServices.Marshal.Copy(valuePtr, valueArray, 0, test1Size);
      return valueArray;
    }
  }

  public int[] Test2
  {
    set {
      test2Size = value.Length;
      global::System.IntPtr valuePtr = System.Runtime.InteropServices.Marshal.UnsafeAddrOfPinnedArrayElement(value, 0);
      _setTest2(valuePtr);
    }
    get {
      global::System.IntPtr valuePtr = _getTest2();
      int[] valueArray = new int[test2Size];
      global::System.Runtime.InteropServices.Marshal.Copy(valuePtr, valueArray, 0, test2Size);
      return valueArray;
    }
  }

  private static int test1Size = 0;
  private static int test2Size = 0;
%}



CSHARP_ARRAYS(char *, string)
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.In, global::System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex=0, ArraySubType=System.Runtime.InteropServices.UnmanagedType.LPStr)]") char *INPUT[] "string[]"
%apply char *INPUT[]  { char** names }

%ignore string_array_test;
%csmethodmodifiers wrapperStringArrayTest "private"

%inline %{
  void wrapperStringArrayTest(char** names, int size) {
    string_array_test((const char*(*))names, size);
  }
%}

%pragma(csharp) modulecode=%{
  public static void StringArrayTest(string[] names, int size) {
    wrapperStringArrayTest(names, size);
  }
%}


%rename("%(camelcase)s") "";

%include "native_code.h"
