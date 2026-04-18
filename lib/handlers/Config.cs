using System;
using System.IO;
using System.Web.Script.Serialization;

namespace Pscs.Demo
{
    public class Config
    {
        public static bool Load(string path, ref string name)
        {
            if (!File.Exists(path))
            {
                Console.Error.WriteLine("Error: config file not found: " + path);
                return false;
            }

            try
            {
                var json = File.ReadAllText(path);
                var data = new JavaScriptSerializer().DeserializeObject(json)
                    as System.Collections.Generic.Dictionary<string, object>;

                if (data != null && data.ContainsKey("name"))
                    name = data["name"] as string;

                Console.WriteLine("Config loaded: " + path);
                return true;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("Error: failed to parse config: " + ex.Message);
                return false;
            }
        }
    }
}
