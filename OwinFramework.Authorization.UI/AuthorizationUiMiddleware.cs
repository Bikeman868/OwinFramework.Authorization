using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Upstream;

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

        private PathString _rootPath;

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            if (!context.Request.Path.StartsWithSegments(_rootPath))
            {
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
                return next();
            }

            var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
            var upstreamAuthorization = context.GetFeature<IUpstreamAuthorization>();

            if (!string.IsNullOrEmpty(_configuration.PermissionToCallApi))
            {
                if (upstreamIdentification != null)
                    upstreamIdentification.AllowAnonymous = false;

                if (upstreamAuthorization != null)
                    upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToCallApi);
            }

            return next();
        }

        public Task Invoke(IOwinContext context, Func<Task> next)
        {
            if (!context.Request.Path.StartsWithSegments(_rootPath))
            {
                Trace(context, () => GetType().Name + " this is not a request for the authorization UI");
                return next();
            }

            return next();
        }

        #region IConfigurable

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

            var root = string.IsNullOrEmpty(configuration.ApiRootUrl) ? "/" : configuration.ApiRootUrl;
            if (!root.StartsWith("/")) root = "/" + root;
            if (!root.EndsWith("/")) root = root + "/";

            _rootPath = new PathString(root);
        }

        #endregion
    }
}
