using System;

namespace Pscs.Demo
{
    public class App
    {
        public static void Run(string[] args)
        {
            string name = null;

            for (int i = 0; i < args.Length; i++)
            {
                switch (args[i])
                {
                    case "--help":
                        Help.Print();
                        return;
                    case "--name":
                        name = args[++i];
                        break;
                }
            }

            Hello.Print(name);
        }
    }
}
