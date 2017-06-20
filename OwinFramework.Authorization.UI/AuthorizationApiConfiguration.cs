using System;

namespace OwinFramework.Authorization
{
    [Serializable]
    internal class AuthorizationApiConfiguration
    {
        public string DocumentationRootUrl { get; set; }
        public string RequiredPermission { get; set; }
        public string ApiRootUrl { get; set; }

        public AuthorizationApiConfiguration()
        {
            DocumentationRootUrl = "/owin/authorizationApi/config";
            ApiRootUrl = "/authorization/api";
            RequiredPermission = "auth.api";
        }
    }
}
