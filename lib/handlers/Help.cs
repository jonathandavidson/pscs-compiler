using System;

namespace Pscs.Demo
{
    public class Help
    {
        public static void Print()
        {
            Console.WriteLine("Usage: app.ps1 [OPTIONS]");
            Console.WriteLine();
            Console.WriteLine("Options:");
            Console.WriteLine("  --name <name>    Name to include in the greeting. Overrides the name");
            Console.WriteLine("                   from --config if both are provided.");
            Console.WriteLine("  --config <path>  Path to a JSON config file. If the file contains a");
            Console.WriteLine("                   'name' property it will be used as the greeting name.");
            Console.WriteLine("  --help           Show this help message.");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine("  app.ps1");
            Console.WriteLine("  app.ps1 --name Alice");
            Console.WriteLine("  app.ps1 --config .\\config.json");
        }
    }
}
