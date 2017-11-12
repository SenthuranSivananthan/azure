using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WebProxy.Model;

namespace WebProxy
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseDeveloperExceptionPage();

            var proxyConfig = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("proxy-config.json", optional: false, reloadOnChange: true)
                .Build()
                .Get<ProxyConfiguration>();

            if (proxyConfig != null)
            {
                foreach (var proxy in proxyConfig.Proxies)
                {
                    app.MapWhen(
                        (context) => { return IsPathMatch(context, proxy.Path); },
                        builder => builder.RunProxy(new ProxyOptions
                            {
                                Scheme = proxy.ProxyProtocol,
                                Host = proxy.ProxyHost,
                                Port = $"{proxy.ProxyPort}"
                            }));
                }
            }
        }

        private static bool IsPathMatch(HttpContext httpContext, string pathPattern)
        {
            return Regex.Match(httpContext.Request.Path.Value, pathPattern).Success;
        }
    }
}
