var appRouter = function(app) {
    app.get("/profile", function(req, res) {
        var request = require('request');
      
        request('http://backend-svc/account', function (error, response, body) {
            console.log(error);
            if (!error && response.statusCode == 200) {
                return res.send(body)
            }
            else
            {
                return res.send("Error!");
            }
        })
    });
}
 
module.exports = appRouter;