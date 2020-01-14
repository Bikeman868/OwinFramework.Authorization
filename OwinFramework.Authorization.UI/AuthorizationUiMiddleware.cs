using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Reflection;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.EmbeddedResources;
using OwinFramework.MiddlewareHelpers.SelfDocumenting;
using OwinFramework.MiddlewareHelpers.Traceable;

namespace OwinFramework.Authorization.UI
{
    /// <summary>
    /// This middleware handles requests for static files that comprise the authorization UI.
    /// These static files are embedded into the assembly to simplify installation and deployment.
    /// </summary>
    public class AuthorizationUiMiddleware :
        IMiddleware<object>,
        IRoutingProcessor,
        ITraceable,
        IConfigurable,
        ISelfDocumenting
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }
        public Action<IOwinContext, Func<string>> Trace { get; set; }

        private readonly ResourceManager _resourceManager;
        private readonly TraceFilter _traceFilter;
        private PathString _uiRootPath;

        public AuthorizationUiMiddleware(IHostingEnvironment hostingEnvironment)
        {
            _resourceManager = new ResourceManager(hostingEnvironment, new MimeTypeEvaluator());
            _traceFilter = new TraceFilter(null, this);

            this.RunAfter<IAuthorization>(null, false);
            this.RunAfter<IIdentification>(null, false);

            ConfigurationChanged(new AuthorizationUiConfiguration());
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            if (context.Request.Path.StartsWithSegments(_uiRootPath))
            {

                if (!string.IsNullOrEmpty(_configuration.PermissionToCallApi))
                {
                    var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                    var upstreamAuthorization = context.GetFeature<IUpstreamAuthorization>();

                    if (upstreamIdentification != null)
                        upstreamIdentification.AllowAnonymous = false;

                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToCallApi);
                }
            }
            else
            {
                _traceFilter.Trace(context, TraceLevel.Debug, () => GetType().Name + " this is not a request for the authorization UI");
            }

            return next();
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            PathString remaining;
            if (!context.Request.Path.StartsWithSegments(_uiRootPath, out remaining) || 
                !remaining.HasValue)
            {
                _traceFilter.Trace(context, TraceLevel.Debug, () => GetType().Name + " this is not a request for the authorization UI");
                return next();
            }

            _traceFilter.Trace(context, TraceLevel.Information, () => GetType().Name + " retrieving UI resource " + remaining.Value);
            var resource = GetResource(remaining.Value);

            if (resource == null)
            {
                _traceFilter.Trace(context, TraceLevel.Error, () => GetType().Name + " UI resource " + remaining.Value + " was not found");
                context.Response.StatusCode = (int) HttpStatusCode.NotFound;
                return context.Response.WriteAsync("");
            }

            _traceFilter.Trace(context, TraceLevel.Debug, () => GetType().Name + " UI resource '" + resource.FileName + "' has mime type " + resource.MimeType);
            context.Response.ContentType = resource.MimeType;

            return context.Response.WriteAsync(resource.Content);
        }

        private IDisposable _configurationRegistration;
        private AuthorizationUiConfiguration _configuration = new AuthorizationUiConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
            _traceFilter.ConfigureWith(configuration);

            _configurationRegistration = configuration.Register(
                path,
                ConfigurationChanged,
                new AuthorizationUiConfiguration());
        }

        private void ConfigurationChanged(AuthorizationUiConfiguration configuration)
        {
            _configuration = configuration;
            _resourceManager.ConfigurationChanged(configuration);

            Func<string, PathString> normalizePath = p =>
            {
                if (string.IsNullOrEmpty(p)) return new PathString();

                p = p.ToLower();
                if (!p.StartsWith("/")) p = "/" + p;
                if (p.Length == 1) return new PathString("/");

                if (p.EndsWith("/")) p = p.Substring(0, p.Length - 1);
                return new PathString(p);
            };

            _uiRootPath = normalizePath(configuration.UiRootUrl);
        }

        private EmbeddedResource GetResource(string filename)
        {
            filename = filename.ToLower();

            if (filename.EndsWith(".css"))
                filename = Path.ChangeExtension(filename, ".less");

            return _resourceManager.GetResource(Assembly.GetExecutingAssembly(), filename);
        }

        #region ISelfDocumenting

        public string ShortDescription
        {
            get { return "A user interface for managing groups, roles and permissions"; }
        }

        public string LongDescription
        {
            get 
            {
                return
                    "<h3>Identity</h3>" +
                    "<p>An identity is anything that has access to the system. This can be a user but also can " +
                    "by a service, third party system or anything else that can send requests over " +
                    "the network</p>" +
                    "<p>When an identity makes a request to the system it must provide evidence of who it is. " +
                    "There are many ways to do this including username and password, IP address, " +
                    "shared secret keys, certificates and social media OAuth login. The job of identifying " +
                    "the identity is not done by this middleware, you need separete Identification middleware " +
                    "for that. After the Identification middleware identifies the identity, then this " +
                    "Authorization middleware has the job of deciding if they are permitted to make the request.</p>" +
                    "<h3>Group</h3>" +
                    "<p>Each identity belongs to a single group and all identities in the " +
                    "group have identical permissions</p>" +
                    "<h3>Role</h3>" +
                    "<p>Each group can have many roles. The role can be thought of as a job or task " +
                    "that the identity is permitted to perform. In order to perform this task the identity " +
                    "will need to have access to a number of features of the system</p>" +
                    "<h3>Permission</h3>" +
                    "<p>Permissions are defined by the application software. These are the things that the " +
                    "application software checks before allowing the request to execute. Permissions are assigned " +
                    "to roles.</p>" +
                    "<p>When checking permissions the application also provides a resource string if appropriate. " +
                    "The resource string defines the entity that the operation is being performed on, and this allows " +
                    "the authorization checks to be a bit more granular. For example in a shopping cart system there " +
                    "could be a request that cancels an order in the system. There would need to be a permission for " +
                    "this, because you don't want everybody to be able to cancel orders, and some identities can " +
                    "have this permission and be allowed to cancel any order, but the application software could " +
                    "also pass the identity of the person who placed the order as the resource, this would allow the " +
                    "permission to be configured to only allow identities to cancel their own orders.</p>";
            }
        }

        public IList<IEndpointDocumentation> Endpoints
        {
            get 
            { return new List<IEndpointDocumentation> 
                { 
                    new EndpointDocumentation
                    {
                        RelativePath = _uiRootPath.ToString(),
                        Description = "Authorization manager user interface"
                    }
                }; 
            }
        }

        public Uri GetDocumentation(DocumentationTypes documentationType)
        {
            return null;
        }

        #endregion
    }
}
