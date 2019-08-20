using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Authorization.Core.Interfaces;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.SelfDocumenting;
using OwinFramework.MiddlewareHelpers.EmbeddedResources;

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
        private readonly ResourceManager _resourceManager;

        public AuthorizationMiddleware(
            IIdentityData identityData,
            IHostingEnvironment hostingEnvironment)
        {
            _identityData = identityData;

            this.RunAfter<IIdentification>();

            _resourceManager = new ResourceManager(hostingEnvironment, new MimeTypeEvaluator());
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            var authorization = new Authorization(_identityData, f => Trace(context, f));
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
                context.Response.StatusCode = (int) HttpStatusCode.Forbidden;
                context.Response.ContentType = "text/plain";
                return context.Response.WriteAsync("No user identification method is configured");
            }

            if (identification.IsAnonymous)
            {
                var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                if (upstreamIdentification == null)
                {
                    Trace(context, () => GetType().Name + " there is no upstream identification so this anonymous request will be permitted");
                }
                else
                {
                    if (upstreamIdentification.AllowAnonymous)
                    {
                        Trace(context, () => GetType().Name + " anonymous access is permitted by upstream identification");
                    }
                    else
                    {
                        Trace(context, () => GetType().Name + " anonymous access to this resource is not permitted");
                        context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
                        context.Response.ContentType = "text/plain";
                        return context.Response.WriteAsync("Anonymous access to this resource is not permitted");
                    }
                }
            }

            var check = authorization.Check(identification);

            if (ReferenceEquals(check, null))
            {
                Trace(context, () => GetType().Name + " the requester is permitted to make this request");
            }
            else
            {
                Trace(context, () => GetType().Name + " returning a 403 Forbidden response because " + check);
                context.Response.StatusCode = (int)HttpStatusCode.Forbidden;
                context.Response.ContentType = "text/plain";
                return context.Response.WriteAsync("Access denied because " + check);
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
            var resource = _resourceManager.GetResource(Assembly.GetExecutingAssembly(), "configuration.html");
            if (resource == null || resource.Content == null)
            {
                context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                context.Response.ContentType = "text/plain";
                return context.Response.WriteAsync("The configuration information template is missing");
            }

            var document = Encoding.UTF8.GetString(resource.Content);
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

        string ISelfDocumenting.ShortDescription
        {
            get { return "Provides a mechanism for defining identity groups, roles and permissions"; }
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

        #endregion

        private class Authorization : IUpstreamAuthorization, IAuthorization
        {
            private readonly IIdentityData _identityData;
            private readonly Action<Func<string>> _trace;
            private readonly List<string> _requiredRoles = new List<string>();
            private readonly List<string> _requiredPermissions = new List<string>();

            private IIdentification _identification;

            public Authorization(
                IIdentityData identityData, 
                Action<Func<string>> trace)
            {
                _identityData = identityData;
                _trace = trace;
            }

            public void AddRequiredPermission(string permissionName)
            {
                _trace(() => GetType().Name + " the '" + permissionName + "' permission is required for this request");

                var permission = string.Intern(permissionName.ToLower());
                if (_requiredPermissions.Any(p => ReferenceEquals(p, permission)))
                    return;

                _requiredPermissions.Add(permission);
            }

            public void AddRequiredRole(string roleName)
            {
                _trace(() => GetType().Name + " the '" + roleName + "' role is required for this request");

                var role = string.Intern(roleName.ToLower());
                if (_requiredRoles.Any(r => ReferenceEquals(r, role)))
                    return;

                _requiredRoles.Add(role);
            }

            public bool HasPermission(string permissionName, string resourceName)
            {
                var result = _identityData.HasPermission(_identification, permissionName, resourceName);

                _trace(() => GetType().Name + " '" + _identification.Identity + 
                    (result ? "' has the '" : "' does not have the '") + permissionName + "' permission" + 
                    (string.IsNullOrEmpty(resourceName) ? "" : " on resource '" + resourceName + "'"));

                return result;
            }

            public bool IsInRole(string roleName)
            {
                var result = _identityData.IsInRole(_identification, roleName);

                _trace(() => GetType().Name + " '" + _identification.Identity + (result ? "' has the '" : "' does not have the '") + roleName + "' role");

                return result;
            }

            public string Check(IIdentification identification)
            {
                if (_requiredPermissions.Count == 0 && _requiredRoles.Count == 0)
                    return null;

                if (ReferenceEquals(identification, null))
                    return "there was no identification";

                _identification = identification;

                if (_requiredRoles.Count > 0 && !_requiredRoles.All(IsInRole))
                    return "you do not have all of the these roles: " + string.Join(", ", _requiredRoles);

                if (_requiredPermissions.Count > 0 && !_requiredPermissions.All(r => HasPermission(r, null)))
                    return "you do not have all of the these permissions: " + string.Join(", ", _requiredPermissions);

                return null;
            }
        }

    }
}
