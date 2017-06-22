using System;

namespace OwinFramework.Authorization
{
    [Serializable]
    internal class AuthorizationConfiguration
    {
        public string DocumentationRootUrl { get; set; }
        public string DefaultIdentityGroup { get; set; }

        public AuthorizationConfiguration()
        {
            DocumentationRootUrl = "/owin/authorization/config";
            DefaultIdentityGroup = "Users";
        }
    }
}
