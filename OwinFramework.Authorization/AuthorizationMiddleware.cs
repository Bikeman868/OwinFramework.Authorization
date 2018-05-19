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
        ISelfDocumenting,
        ITraceable
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }
        public Action<IOwinContext, Func<string>> Trace { get; set; }

        private readonly IIdentityData _identityData;

        public AuthorizationMiddleware(IIdentityData identityData)
        {
            _identityData = identityData;

            this.RunAfter<IIdentification>();
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            var authorization = new Authorization(_identityData, s => Trace(context, () => s));
            context.SetFeature<IUpstreamAuthorization>(authorization);

            return next();
        }

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            if (!string.IsNullOrEmpty(_configuration.DocumentationRootUrl) &&
                context.Request.Path.Value.Equals(_configuration.DocumentationRootUrl, StringComparison.OrdinalIgnoreCase))
            {
                Trace(context, () => GetType().Name + " returning configuration documentation");
                return DocumentConfiguration(context);
            }

            var authorization = context.GetFeature<IUpstreamAuthorization>() as Authorization;
            var identification = context.GetFeature<IIdentification>();

            if (identification == null || authorization == null)
            {
                Trace(context, () => GetType().Name + " identification middleware is missing from the owin context");
                throw new HttpException((int)HttpStatusCode.Forbidden, "Caller identification is missing");
            }

            if (identification.IsAnonymous)
            {
                Trace(context, () => GetType().Name + " caller is anonymous");
                var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                if (upstreamIdentification != null && !upstreamIdentification.AllowAnonymous)
                {
                    Trace(context, () => GetType().Name + " anonymous access is not permitted to this resource");
                    throw new HttpException((int)HttpStatusCode.Forbidden, "Anonymous access is not permitted");
                }
            }

            authorization.Identification = identification;
            if (authorization.IsAllowed())
            {
                Trace(context, () => GetType().Name + " the requesting identity is permitted to make this request");
            }
            else
            {
                Trace(context, () => GetType().Name + " returning a 403 Forbidden response");
                throw new HttpException((int)HttpStatusCode.Forbidden,
                    "You do not have permission to perform this operation");
            }
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
            get { return 
                "<p>Provides a mechanism for defining identity groups, roles and permissions.</p>"+
                "<p>Identities (users, computers, services etc) can be assigned to a group, all " +
                "identities in the same group have identical permissions.</p>" +
                "<p>Roles define the jobs that identities can do, and permissions define the " +
                "things that identities need to have access to to be able to do that job. For " +
                "example there could be a role of producing the company payroll that needs permission "+
                "to access employee salaries.<p>" +
                "<p>Permissions are defined by the software development team. These are the things that "+
                "the software will check before executing a request. For example if an identity makes "+
                "an API call to retrieve an employee's salary the software will check that the calling "+
                "identity has this permission before returning the salary information.</p>"; }
        }

        string ISelfDocumenting.ShortDescription
        {
            get { return "Provides a mechanism for defining identity groups, roles and permissions"; }
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
            private readonly IIdentityData _identityData;
            private readonly Action<string> _trace;
            public IIdentification Identification;

            private readonly List<string> _requiredRoles = new List<string>();
            private readonly List<string> _requiredPermissions = new List<string>();

            public Authorization(
                IIdentityData identityData, 
                Action<string> trace)
            {
                _identityData = identityData;
                _trace = trace;
            }

            public void AddRequiredPermission(string permissionName)
            {
                _trace(GetType().Name + " the '" + permissionName + "' permission is required for this request");

                permissionName = string.Intern(permissionName.ToLower());
                if (_requiredPermissions.Any(p => ReferenceEquals(p, permissionName)))
                    return;
                _requiredPermissions.Add(permissionName);
            }

            public void AddRequiredRole(string roleName)
            {
                _trace(GetType().Name + " the '" + roleName + "' role is required for this request");

                roleName = string.Intern(roleName.ToLower());
                if (_requiredRoles.Any(p => ReferenceEquals(p, roleName)))
                    return;
                _requiredRoles.Add(roleName);
            }

            public bool HasPermission(string permissionName, string resourceName)
            {
                var result = _identityData.HasPermission(Identification, permissionName, resourceName);

                if (!result)
                    _trace(
                        GetType().Name + " '" + Identification.Identity + 
                        "' does not have '" + permissionName + "' permission" + 
                        (string.IsNullOrEmpty(resourceName) ? "" : " on resource '" + 
                        resourceName + "'"));

                return result;
            }

            public bool IsInRole(string roleName)
            {
                var result = _identityData.IsInRole(Identification, roleName);

                if (!result)
                    _trace(GetType().Name + " '" + Identification.Identity + " does not have '" + roleName + "' role");

                return result;
            }

            public bool IsAllowed()
            {
                if (ReferenceEquals(Identification, null))
                {
                    _trace(GetType().Name + " not allowed because there is no identification");
                    return false;
                }

                if (!_requiredRoles.All(IsInRole))
                {
                    _trace(GetType().Name + " not allowed because the user does not have all of the required roles");
                    return false;
                }

                if (!_requiredPermissions.All(r => HasPermission(r, null)))
                {
                    _trace(GetType().Name + " not allowed because the user does not have all of the required permissions");
                    return false;
                }

                return true;
            }
        }

    }
}
