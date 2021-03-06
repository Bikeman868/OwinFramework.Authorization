﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Authorization.Core.Interfaces;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.Authorization.Core.DataContracts;

namespace TestWebsite.Middleware
{
    public class CheckPermissionMiddleware :
        IMiddleware<IResponseProducer>,
        IRoutingProcessor
    {
        string IMiddleware.Name { get; set; }

        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }

        private readonly IAuthorizationData _authorizationData;

        public CheckPermissionMiddleware(
            IAuthorizationData authorizationData)
        {
            _authorizationData = authorizationData;

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

            var response = new StringBuilder();

            if (identification == null)
            {
                response.AppendLine("No identification middleware configured");
            }
            else
            {
                if (identification.IsAnonymous)
                {
                    response.AppendLine("Unidentified user");
                }
                else
                {
                    response.AppendLine("User identified as " + identification.Identity);

                    Group group;
                    List<string> roles;
                    List<string> permissions;
                    _authorizationData.GetIdentity(identification, out group, out roles, out permissions);

                    response.AppendLine("   User is in the " + group.DisplayName + " group");
                    response.AppendLine("   User has the role of " + string.Join(" and ", roles));
                    response.AppendLine("   User has permissions to " + string.Join(" and ", permissions));
                }

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

                if (identification.Purposes != null && identification.Purposes.Count > 0)
                {
                    response.AppendLine();
                    response.AppendLine("The identified user is restricted to these roles:");
                    foreach (var purpose in identification.Purposes)
                    {
                        response.AppendFormat("   {0}", purpose);
                        response.AppendLine();
                    }
                }

                response.AppendLine();

                var authorization = context.GetFeature<IAuthorization>();
                if (authorization == null)
                {
                    response.AppendLine("Authorization middleware is not properly configured");
                }
                else
                {
                    if (!string.IsNullOrEmpty(role))
                    {
                        if (authorization.IsInRole(role))
                            response.AppendLine("This user has the role of " + role);
                        else
                            response.AppendLine("This user does not have the role of " + role);
                    }

                    if (!string.IsNullOrEmpty(permission))
                    {
                        var hasPermission = authorization.HasPermission(permission, resource);
                        if (string.IsNullOrEmpty(resource))
                        {
                            if (hasPermission)
                                response.AppendLine("This user has permission to " + permission);
                            else
                                response.AppendLine("This user does not have permission to " + permission);
                        }
                        else
                        {
                            if (hasPermission)
                                response.AppendLine("This user has permission to " + permission + " on " + resource);
                            else
                                response.AppendLine("This user does not have permission to " + permission + " on " +
                                                    resource);
                        }
                    }
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