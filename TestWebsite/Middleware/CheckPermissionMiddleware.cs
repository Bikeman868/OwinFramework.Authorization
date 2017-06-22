using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;

namespace TestWebsite.Middleware
{
    public class CheckPermissionMiddleware: 
        IMiddleware<IResponseProducer>,
        IRoutingProcessor
    {
        string IMiddleware.Name { get; set; }

        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }

        public CheckPermissionMiddleware()
        {
            this.RunAfter<IAuthorization>();
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            if (!IsForMe(context)) return next();

            var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
            if (upstreamIdentification != null)
                upstreamIdentification.AllowAnonymous = true;

            return next();
        }

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            if (!IsForMe(context)) return next();

            var permission = context.Request.Query["permission"];
            var resource = context.Request.Query["resource"];
            var role = context.Request.Query["role"];

            var identification = context.GetFeature<IIdentification>();
            var authorization = context.GetFeature<IAuthorization>();

            var response = new StringBuilder();

            if (identification.IsAnonymous)
                response.AppendLine("Unidentified user");
            else
                response.AppendLine("User identified as " + identification.Identity);

            if (identification.Claims != null && identification.Claims.Count > 0)
            {
                response.AppendLine();
                response.AppendLine("The identified user is making the following claims:");
                foreach (var claim in identification.Claims)
                {
                    response.AppendFormat("   {0} = {1} [{2}]", claim.Name, claim.Value, claim.Status);
                    response.AppendLine();
                }
            }

            response.AppendLine();

            if (!string.IsNullOrEmpty(role))
            {
                if (authorization.IsInRole(role))
                    response.AppendLine("This user has the role of " + role);
                else
                    response.AppendLine("This user does not have the role of " + role);
            }

            if (!string.IsNullOrEmpty(permission))
            {
                if (string.IsNullOrEmpty(resource))
                {
                    if (authorization.HasPermission(permission))
                        response.AppendLine("This user has permission to " + permission);
                    else
                        response.AppendLine("This user does not have permission to " + permission);
                }
                else
                {
                    if (authorization.HasPermission(permission))
                        response.AppendLine("This user has permission to " + permission + " on " + resource);
                    else
                        response.AppendLine("This user does not have permission to " + permission + " on " + resource);
                }
            }

            context.Response.ContentType = "text/plain";
            return context.Response.WriteAsync(response.ToString());
        }

        private bool IsForMe(IOwinContext context)
        {
            return 
                context.Request.Method == "GET" &&
                string.Equals(context.Request.Path.Value, "/check", StringComparison.OrdinalIgnoreCase);
        }
    }
}