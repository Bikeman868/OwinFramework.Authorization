using System;

namespace OwinFramework.Authorization
{
    [Serializable]
    internal class AuthorizationConfiguration
    {
        public string DocumentationRootUrl { get; set; }
        public string DefaultUserGroup { get; set; }

        public AuthorizationConfiguration()
        {
            DocumentationRootUrl = "/owin/authorization/config";
            DefaultUserGroup = "User";
        }
    }
}
