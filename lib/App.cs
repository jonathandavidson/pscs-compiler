using System;
using System.Net;
using System.IO;

namespace Pscs.Demo
{
    public class App
    {
        public static void Run(string[] args)
        {
            string url     = null;
            int    timeout = 10000;
            bool   headersOnly = false;

            for (int i = 0; i < args.Length; i++)
            {
                switch (args[i])
                {
                    case "--url":
                        url = args[++i];
                        break;
                    case "--timeout":
                        timeout = int.Parse(args[++i]);
                        break;
                    case "--headers":
                        headersOnly = true;
                        break;
                    default:
                        Console.Error.WriteLine("Unknown argument: " + args[i]);
                        PrintUsage();
                        return;
                }
            }

            if (url == null) { PrintUsage(); return; }

            var request = (HttpWebRequest)WebRequest.Create(url);
            request.Timeout   = timeout;
            request.UserAgent = "Pscs.Demo.App/1.0";

            using (var response = (HttpWebResponse)request.GetResponse())
            {
                Console.WriteLine("Status : {0} {1}", (int)response.StatusCode, response.StatusDescription);
                Console.WriteLine("Type   : {0}", response.ContentType);
                Console.WriteLine("Length : {0}", response.ContentLength < 0 ? "unknown" : response.ContentLength + " bytes");

                if (headersOnly) return;

                Console.WriteLine();
                using (var reader = new StreamReader(response.GetResponseStream()))
                    Console.WriteLine(reader.ReadToEnd());
            }
        }

        private static void PrintUsage()
        {
            Console.WriteLine("Usage: app.ps1 --url <url> [--timeout <ms>] [--headers]");
        }
    }
}
