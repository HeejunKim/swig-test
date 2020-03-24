using System;

using SwigTest;

namespace Sample {
    class SwigTestSample {
        static void Main() {
            Console.WriteLine("Hello Swig Test");

            int result = NativeCode.fact(10);
            Console.WriteLine("fact : " + result);

            int result1 = NativeCode.my_mod(2, 5);
            Console.WriteLine("my_mode : " + result1);
        }
    }
}
