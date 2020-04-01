using System;

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
        }

        public static void CallbackTest(string str)
        {
            Console.WriteLine("CallbakcTest : {0}", str);
        }

        static void PrintArray(int[] a) {
            foreach(int i in a) {
                Console.Write("{0} ", i);
            }
            Console.WriteLine(" ");
        }
    }
}
