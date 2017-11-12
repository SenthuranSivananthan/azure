var http = require('http'),
httpProxy = require('http-proxy');

//
// Create a proxy server with custom application logic
//
var proxy = httpProxy.createProxyServer({});

//
// Create your custom server and just call `proxy.web()` to proxy
// a web request to the target passed in the options
// also you can use `proxy.ws()` to proxy a websockets request
//
var server = http.createServer(function(req, res) {
// You can define here your custom logic to handle the request
// and then proxy the request.
proxy.web(req, res, { 
                        target: 'http://appserver:9000',
                        changeOrigin: true
                 });
});

var port = process.env.PORT || 1337;
server.listen(port);

console.log("Server running at http://:%d", port);
