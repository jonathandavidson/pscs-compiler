using System;

namespace Pscs.Demo
{
    public class Hello
    {
        public static void Print(string name = null)
        {
            Console.WriteLine(name == null ? "Hello, World!" : "Hello, " + name + "!");
        }
    }
}
