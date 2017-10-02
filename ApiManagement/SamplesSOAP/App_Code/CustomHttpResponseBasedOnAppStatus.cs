using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

/// <summary>
/// Summary description for CustomHttpResponseBasedOnAppStatus
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class CustomHttpResponseBasedOnAppStatus : System.Web.Services.WebService
{

    public CustomHttpResponseBasedOnAppStatus()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public ApplicationStatus Hello(string input)
    {
        if (string.IsNullOrEmpty(input))
        {
            return new ApplicationStatus { Code = "InvalidInput", Message = "Invalid Input" };
        }
        else if (input.Trim().Length <= 5)
        {
            return new ApplicationStatus { Code = "TextTooSmall", Message = "Text too small" };
        }

        return new ApplicationStatus { Code = "Success", Message = "Input accepted" };
    }


    public class ApplicationStatus
    {
        public string Code { get; set; }
        public string Message { get; set; }
    }
}
