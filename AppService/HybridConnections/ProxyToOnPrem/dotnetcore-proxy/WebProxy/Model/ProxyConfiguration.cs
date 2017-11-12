using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebProxy.Model
{
    public class ProxyConfiguration
    {
        public List<Proxy> Proxies { get; set; }
    }

    public class Proxy
    {
        public string Path { get; set; }
        public string ProxyProtocol { get; set; }
        public string ProxyHost { get; set; }
        public int ProxyPort { get; set; }
    }
}
