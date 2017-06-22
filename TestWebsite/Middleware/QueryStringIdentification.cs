﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.Identification;

namespace TestWebsite.Middleware
{
    /// <summary>
    /// For testing only. Identify by adding &identity=... to the query string
    /// </summary>
    internal class QueryStringIdentification: 
        IMiddleware<IIdentification>,
        IUpstreamCommunicator<IUpstreamIdentification>
    {
        string IMiddleware.Name { get; set; }

        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            var identification = (Identification)context.GetFeature<IUpstreamIdentification>();
            context.SetFeature<IIdentification>(identification);

            return next();
        }

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            var identity = context.Request.Query["identity"];
            var claims = new List<IIdentityClaim>();

            if (identity == null)
            {
                identity = context.Request.Cookies["identity"];
            }
            else if (identity.Length == 0)
            {
                context.Response.Cookies.Delete("identity");
            }
            else
            {
                context.Response.Cookies.Append("identity", identity);
            }

            if (!string.IsNullOrEmpty(identity))
            {
                claims.Add(new IdentityClaim(ClaimNames.Email, "someone@mailinator.com", ClaimStatus.Verified));
                claims.Add(new IdentityClaim(ClaimNames.IpV4, context.Request.RemoteIpAddress, ClaimStatus.Verified));
            };

            var identification = new Identification(identity, claims);
            identification.AllowAnonymous = true;
            context.SetFeature<IUpstreamIdentification>(identification);

            return next();
        }
    }
}
