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
                    Console.WriteLine("Usage: app.ps1 [--help]");
                    return;
                }
            }

            Console.WriteLine("Hello, World!");
        }
    }
}
