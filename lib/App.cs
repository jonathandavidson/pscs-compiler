using System;

namespace Pscs.Demo
{
    public class App
    {
        public static void Run(string[] args)
        {
            foreach (var arg in args)
            {
                if (arg == "--help")
                {
                    Help.Print();
                    return;
                }
            }

            Console.WriteLine("Hello, World!");
        }
    }
}
