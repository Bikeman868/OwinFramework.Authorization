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
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.Interfaces.Utility;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.EmbeddedResources;

namespace OwinFramework.Authorization.UI
{
    public class AuthorizationUiMiddleware:
        IMiddleware<object>,
        IRoutingProcessor,
        ITraceable,
        IConfigurable
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }
        public Action<IOwinContext, Func<string>> Trace { get; set; }

        private readonly ResourceManager _resourceManager;

        private PathString _uiRootPath;

        public AuthorizationUiMiddleware(IHostingEnvironment hostingEnvironment)
        {
            _resourceManager = new ResourceManager(hostingEnvironment, new MimeTypeEvaluator());

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
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
            }

            return next();
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            PathString remaining;
            if (!context.Request.Path.StartsWithSegments(_uiRootPath, out remaining) || 
                !remaining.HasValue)
            {
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
                return next();
            }

            var resource = GetResource(remaining.Value);
            if (resource == null)
                throw new HttpException((int)HttpStatusCode.NotFound, "No resource '" + remaining.Value + "'");

            context.Response.ContentType = resource.MimeType;
            return context.Response.WriteAsync(resource.Content);
        }

        private IDisposable _configurationRegistration;
        private AuthorizationUiConfiguration _configuration = new AuthorizationUiConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
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
    }
}
