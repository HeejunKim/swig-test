using System;

using SwigTest;

namespace Sample {
    class SwigTestSample {
        public static void Main() {
            Console.WriteLine("=========== Swig Default Test ===========");

            int result = NativeCode.fact(10);
            Console.WriteLine("fact : " + result);

            int result1 = NativeCode.my_mod(2, 5);
            Console.WriteLine("my_mode : " + result1);

            Console.WriteLine("=========== Swig Array Test ===========");
            int[] source = {1, 2, 3};
            int[] target = new int[source.Length];

            NativeCode.my_array_copy(source, target, target.Length);
            Console.WriteLine("Contents of copy target array using default marshaling");
            PrintArray(target);

            target = new int[source.Length];
            NativeCode.myArrayCopyUsingFixedArrays(source, target, target.Length);
            Console.WriteLine("Contents of copy target array using fixed arrays");
            PrintArray(target);

            target = new int[] {4, 5, 6};
            NativeCode.my_array_swap(source, target, target.Length);
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
            
            test_info_t info = new test_info_t();
            info.building_name = "shinagawa";
            info.office_name = "jr office";
            info.persion_name = "joso";

            TextClient textClient = new TextClient("http://google.com", "english", info);
            string urlStr = NativeCode.get_test_string(textClient);
            Console.WriteLine("url string : " + urlStr);
            string language = NativeCode.get_test_lang(textClient);
            Console.WriteLine("language : " + language);
        }

        static void PrintArray(int[] a) {
            foreach(int i in a) {
                Console.Write("{0} ", i);
            }
            Console.WriteLine(" ");
        }
    }
}
