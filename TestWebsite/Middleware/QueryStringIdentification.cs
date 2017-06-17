using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;

namespace TestWebsite.Middleware
{
    /// <summary>
    /// For testing only. Identify user by adding &user=... to the query string
    /// </summary>
    internal class QueryStringIdentification: 
        IMiddleware<IIdentification>,
        IUpstreamCommunicator<IUpstreamIdentification>
    {
        string IMiddleware.Name { get; set; }

        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }

        Task IMiddleware.Invoke(IOwinContext context, System.Func<Task> next)
        {
            return next();
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, System.Func<Task> next)
        {
            return next();
        }
    }
}
