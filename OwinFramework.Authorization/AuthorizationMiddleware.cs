using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using OwinFramework.Authorization.Data.Interfaces;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.SelfDocumenting;

namespace OwinFramework.Authorization
{
    public class AuthorizationMiddleware:
        IMiddleware<IAuthorization>,
        IUpstreamCommunicator<IUpstreamAuthorization>,
        IConfigurable,
        ISelfDocumenting
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }

        private readonly IAuthorizationData _authorizationData;

        public AuthorizationMiddleware(IAuthorizationData authorizationData)
        {
            _authorizationData = authorizationData;

            this.RunAfter<IIdentification>();
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            var authorization = new Authorization(_authorizationData);
            context.SetFeature<IUpstreamAuthorization>(authorization);

            return next();
        }

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            if (!string.IsNullOrEmpty(_configuration.DocumentationRootUrl) &&
                context.Request.Path.Value.Equals(_configuration.DocumentationRootUrl, StringComparison.OrdinalIgnoreCase))
            {
                return DocumentConfiguration(context);
            }

            var authorization = context.GetFeature<IUpstreamAuthorization>() as Authorization;
            var identification = context.GetFeature<IIdentification>();

            if (identification == null || authorization == null)
                throw new HttpException((int)HttpStatusCode.Forbidden, "Caller identification is missing");

            if (identification.IsAnonymous)
            {
                var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                if (upstreamIdentification != null && !upstreamIdentification.AllowAnonymous)
                    throw new HttpException((int) HttpStatusCode.Forbidden, "Anonymous access is not permitted");
            }

            authorization.Identification = identification;
            if (!authorization.IsAllowed())
                throw new HttpException((int) HttpStatusCode.Forbidden,
                    "You do not have permission to perform this operation");
            context.SetFeature<IAuthorization>(authorization);

            return next();
        }

        #region IConfigurable

        private IDisposable _configurationRegistration;
        private AuthorizationConfiguration _configuration = new AuthorizationConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
            _configurationRegistration = configuration.Register(
                path,
                cfg =>
                {
                    _configuration = cfg;
                },
                new AuthorizationConfiguration());
        }

        #endregion

        #region ISelfDocumenting

        private Task DocumentConfiguration(IOwinContext context)
        {
            var document = GetScriptResource("configuration.html");
            document = document.Replace("{documentationRootUrl}", _configuration.DocumentationRootUrl);

            var defaultConfiguration = new AuthorizationConfiguration();
            document = document.Replace("{documentationRootUrl.default}", defaultConfiguration.DocumentationRootUrl);

            context.Response.ContentType = "text/html";
            return context.Response.WriteAsync(document);
        }
        
        IList<IEndpointDocumentation> ISelfDocumenting.Endpoints
        {
            get 
            {
                var documentation = new List<IEndpointDocumentation>();
                if (!string.IsNullOrEmpty(_configuration.DocumentationRootUrl))
                {
                    documentation.Add(
                        new EndpointDocumentation
                        {
                            RelativePath = _configuration.DocumentationRootUrl,
                            Description = "Documentation for the configuratrion of this middleware",
                            Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns documentation on the configuration of the Authorization middleware."
                                    }
                                }
                        });
                }
                return documentation;
            }
        }

        Uri ISelfDocumenting.GetDocumentation(DocumentationTypes documentationType)
        {
            switch (documentationType)
            {
                case DocumentationTypes.Configuration:
                    return new Uri(_configuration.DocumentationRootUrl, UriKind.Relative);
                case DocumentationTypes.Overview:
                    return new Uri("https://github.com/Bikeman868/OwinFramework.Authorization/blob/master/README.md", UriKind.Absolute);
                case DocumentationTypes.SourceCode:
                    return new Uri("https://github.com/Bikeman868/OwinFramework.Authorization/tree/master/OwinFramework.Authorization", UriKind.Absolute);
            }
            return null;
        }

        string ISelfDocumenting.LongDescription
        {
            get { return "Provides a mechanism for defining identity groups, roles and permissionn"; }
        }

        string ISelfDocumenting.ShortDescription
        {
            get { return "Provides a mechanism for defining identity groups, roles and permissionn"; }
        }

        #endregion

        #region Embedded resources

        private string GetScriptResource(string filename)
        {
            var scriptResourceName = Assembly.GetExecutingAssembly()
                .GetManifestResourceNames()
                .FirstOrDefault(n => n.Contains(filename));
            if (scriptResourceName == null)
                throw new Exception("Failed to find embedded resource " + filename);

            using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(scriptResourceName))
            {
                if (stream == null)
                    throw new Exception("Failed to open embedded resource " + scriptResourceName);

                using (var reader = new StreamReader(stream, Encoding.UTF8))
                {
                    return reader.ReadToEnd();
                }
            }
        }

        #endregion

        private class Authorization : IUpstreamAuthorization, IAuthorization
        {
            private readonly IAuthorizationData _authorizationData;
            public IIdentification Identification;

            private readonly List<string> _requiredRoles = new List<string>();
            private readonly List<string> _requiredPermissions = new List<string>();

            public Authorization(IAuthorizationData authorizationData)
            {
                _authorizationData = authorizationData;
            }

            public void AddRequiredPermission(string permissionName)
            {
                permissionName = string.Intern(permissionName.ToLower());
                if (_requiredPermissions.Any(p => ReferenceEquals(p, permissionName)))
                    return;
                _requiredPermissions.Add(permissionName);
            }

            public void AddRequiredRole(string roleName)
            {
                roleName = string.Intern(roleName.ToLower());
                if (_requiredRoles.Any(p => ReferenceEquals(p, roleName)))
                    return;
                _requiredRoles.Add(roleName);
            }

            public bool HasPermission(string permissionName, string resourceName)
            {
                return _authorizationData.HasPermission(Identification, permissionName, resourceName);
            }

            public bool IsInRole(string roleName)
            {
                return _authorizationData.IsInRole(Identification, roleName);
            }

            public bool IsAllowed()
            {
                if (ReferenceEquals(Identification, null)) return false;
                return _requiredRoles.All(IsInRole) && _requiredPermissions.All(r => HasPermission(r, null));
            }
        }
    }
}
