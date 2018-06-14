var appRouter = function(app) {
    app.get("/account", function(req, res) {
        var accountMock = {
            "username": "senthuran",
            "accountNumber": "5555-1234-5555-6789",
            "email":"senthuran.sivananthan@microsoft.com"
        }
        
        return res.send(accountMock);
    });
}
 
module.exports = appRouter;