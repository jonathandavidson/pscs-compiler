using System;

namespace Pscs.Demo
{
    public class App
    {
        public static void Run(string[] args)
        {
            string name   = null;
            string config = null;

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
                    case "--config":
                        config = args[++i];
                        break;
                }
            }

            if (config != null && !Config.Load(config, ref name))
                return;

            Hello.Print(name);
        }
    }
}
