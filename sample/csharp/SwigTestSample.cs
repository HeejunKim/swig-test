using System;
using System.Runtime.InteropServices;

using SwigTest;

namespace Sample {
    class SwigTestSample {
        public static void Main() {
            Console.WriteLine("=========== Swig Default Test ===========");

            int result = NativeCode.Fact(10);
            Console.WriteLine("fact : " + result);

            int result1 = NativeCode.MyMod(2, 5);
            Console.WriteLine("my_mode : " + result1);

            Console.WriteLine("=========== Swig Array Test ===========");
            int[] source = {1, 2, 3};
            int[] target = new int[source.Length];

            NativeCode.MyArrayCopy(source, target, target.Length);
            Console.WriteLine("Contents of copy target array using default marshaling");
            PrintArray(target);

            target = new int[source.Length];
            NativeCode.myArrayCopyUsingFixedArrays(source, target, target.Length);
            Console.WriteLine("Contents of copy target array using fixed arrays");
            PrintArray(target);

            target = new int[] {4, 5, 6};
            NativeCode.MyArraySwap(source, target, target.Length);
            Console.WriteLine("Contents of arrays after swapping using default marshaling");
            PrintArray(source);
            PrintArray(target);

            source = new int[] {1, 2, 3};
            target = new int[] {4, 5, 6};

            NativeCode.myArraySwapUsingFixedArrays(source, target, target.Length);
            Console.WriteLine("Contents of arrays after swapping using fixed arrays");
            PrintArray(source);
            PrintArray(target);

            Console.WriteLine("=========== Swig Struct Test ===========");
            
            TestInfo info = new TestInfo();
            info.BuildingName = "shinagawa";
            info.OfficeName = "jr office";
            info.PersionName = "joso";

            TextClient textClient = new TextClient("http://google.com", "english", info, TestType.TESTTYPEOK);
            string urlStr = NativeCode.GetTestString(textClient);
            Console.WriteLine("url string : " + urlStr);
            string language = NativeCode.GetTestLang(textClient);
            Console.WriteLine("language : " + language);

            Console.WriteLine("=========== Swig function pointer ===========");
            FuncPtCallback callback = new FuncPtCallback(CallbackTest);
            NativeCode.TestExec("Called C Function pointer??", callback);

            FuncPtCallback callback1 = new FuncPtCallback(CallbackTest1);
            NativeCode.TestExec("No Problem Callback", callback1);

            FuncPtIntCallback intCallback = new FuncPtIntCallback(IntCallbackTest);
            NativeCode.SetCallback(intCallback);

            Console.WriteLine("=========== Swig struct with function pointer ===========");
            FuncPtrStructTest structPtrFuncTest = new FuncPtrStructTest();
            structPtrFuncTest.Func1 = Func1CallbackTest;
            structPtrFuncTest.Func2 = Func2CallbackTest;
            structPtrFuncTest.Func3 = Func3CallbackTest;
            structPtrFuncTest.GetFuncData = GetFuncDataCallbackTest;
            
            NativeCode.RegistFuncPtrStruct(structPtrFuncTest);
            
            NativeCode.CallStructFunc1();
            NativeCode.CallStructFunc2();
            NativeCode.CallStructFunc3();
            NativeCode.CallStructGetFuncData();

            FuncPtrTest funcPtrTest = new FuncPtrTest();
            funcPtrTest.SetFuncPtrStructTest = SetFuncPtrStructTestCallback;

            NativeCode.RegistAndCallFuncPtrs(funcPtrTest);

            Console.WriteLine("=========== Swig Test End ===========");
        }

        public static void CallbackTest(string str)
        {
            Console.WriteLine("CallbakcTest : {0}", str);
        }

        public static void CallbackTest1(string str)
        {
            Console.WriteLine("CallbackTest1 : {0}!!!!!", str);
        }

        public static int Func1CallbackTest(global::System.IntPtr args)
        {
            Console.WriteLine("CSharp Callback 1 Argument value : {0}", Marshal.PtrToStringAuto(args));
            return 3;
        }

        public static int Func2CallbackTest(int args)
        {
            Console.WriteLine("CSharp Callback 2 Argument value : {0}", args);
            return 5+args;
        }

        public static void Func3CallbackTest(string arg)
        {
            Console.WriteLine("CSharp Callback 3 Argument value : {0}", arg);
        }

        public static bool GetFuncDataCallbackTest(out byte[] data, int size)
        {
            string testStr = "";
            testStr = testStr.PadRight(size, 'a');
            data = System.Text.Encoding.Default.GetBytes(testStr);
            return true;
        }

        public static int IntCallbackTest(string arg1, string arg2, global::System.IntPtr userData)
        {
            Console.WriteLine("Called C# Callback : {0}, {1}", arg1, arg2);
            Console.WriteLine("C Thread ID : {0}", userData);
            return 3;
        }

        public static void SetFuncPtrStructTestCallback(FuncPtrStructTest funcCallback, global::System.IntPtr userData)
        {
            Console.WriteLine("[SetFuncPtrStructTestCallback] Called C# Callback");
            Console.WriteLine("=================================================");
            HandleRef strictHandle = FuncPtrStructTest.getCPtr(funcCallback);
            long address = strictHandle.Handle.ToInt64();
            Console.WriteLine("callback structPtrFuncTest address int64 : {0}", address);
            IntPtr info = Marshal.StringToHGlobalAuto("csharp called");
            funcCallback.Func1(info);
            funcCallback.Func2(989898);
            funcCallback.Func3("callback csharp func3!!");
            byte[] testData = new byte[5];
            funcCallback.GetFuncData(out testData, testData.Length);
            string testDataStr = System.Text.Encoding.UTF8.GetString(testData);
            Console.WriteLine("callback structPtrFuncTest testData : {0}", testDataStr);
            Console.WriteLine("=================================================");
        }

        static void PrintArray(int[] a) {
            foreach(int i in a) {
                Console.Write("{0} ", i);
            }
            Console.WriteLine(" ");
        }
    }
}
