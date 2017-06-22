using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Owin;
using OwinFramework.Authorization.Data.Interfaces;
using OwinFramework.Builder;
using OwinFramework.Interfaces.Builder;
using OwinFramework.Interfaces.Routing;
using OwinFramework.InterfacesV1.Capability;
using OwinFramework.InterfacesV1.Middleware;
using OwinFramework.InterfacesV1.Upstream;
using OwinFramework.MiddlewareHelpers.SelfDocumenting;

namespace OwinFramework.Authorization.UI
{
    public class AuthorizationApiMiddleware:
        IMiddleware<IAuthorization>,
        IUpstreamCommunicator<IUpstreamAuthorization>,
        IConfigurable,
        ISelfDocumenting
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }

        private readonly IAuthorizationData _authorizationData;

        private PathString _groupListPath;
        private PathString _groupPath;
        private PathString _groupRoleListPath;

        private PathString _roleListPath;
        private PathString _rolePath;
        private PathString _rolePermissionListPath;

        private PathString _permissionListPath;
        private PathString _permissionPath;

        private PathString _searchIdentityListPath;
        private PathString _identityGroupPath;

        public AuthorizationApiMiddleware(IAuthorizationData authorizationData)
        {
            _authorizationData = authorizationData;

            this.RunAfter<IAuthorization>(null, false);
            this.RunAfter<IIdentification>(null, false);
        }

        #region Request routing

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            if (!string.IsNullOrEmpty(_configuration.RequiredPermission))
            {
                var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
                if (upstreamIdentification != null)
                    upstreamIdentification.AllowAnonymous = false;

                var upstreamAuthorization = context.GetFeature<IUpstreamAuthorization>();
                if (upstreamAuthorization != null)
                    upstreamAuthorization.AddRequiredPermission(_configuration.RequiredPermission);
            }

            return next();
        }

        #endregion

        #region Request handling

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            if (!string.IsNullOrEmpty(_configuration.DocumentationRootUrl) &&
                context.Request.Path.Value.Equals(_configuration.DocumentationRootUrl, StringComparison.OrdinalIgnoreCase))
            {
                return DocumentConfiguration(context);
            }

            var authorization = context.GetFeature<IAuthorization>();


            return next();
        }

        #endregion

        #region IConfigurable

        private IDisposable _configurationRegistration;
        private AuthorizationApiConfiguration _configuration = new AuthorizationApiConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
            _configurationRegistration = configuration.Register(
                path,
                cfg =>
                {
                    _configuration = cfg;

                    var root = string.IsNullOrEmpty(cfg.ApiRootUrl) ? "/" : cfg.ApiRootUrl;
                    if (!root.StartsWith("/")) root = "/" + root;
                    if (!root.EndsWith("/")) root = root + "/";

                    _groupListPath = new PathString(root + "groups");
                    _groupPath = new PathString(root + "group");
                    _groupRoleListPath = new PathString(root + "group/roles");

                    _roleListPath = new PathString(root + "roles");
                    _rolePath = new PathString(root + "role");
                    _rolePermissionListPath = new PathString(root + "role/permissions");

                    _permissionListPath = new PathString(root + "permissions");
                    _permissionPath = new PathString(root + "permission");

                    _searchIdentityListPath = new PathString(root + "identity/_search");
                    _identityGroupPath = new PathString(root + "identity/group");
                },
                new AuthorizationApiConfiguration());
        }

        #endregion

        #region ISelfDocumenting

        private Task DocumentConfiguration(IOwinContext context)
        {
            var document = GetScriptResource("configuration.html");
            document = document.Replace("{documentationRootUrl}", _configuration.DocumentationRootUrl);

            var defaultConfiguration = new AuthorizationApiConfiguration();
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

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _groupListPath.Value,
                        Description = "The list of groups. Each identity (user, machine, service) is assigned to a single group",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of identity groups"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "POST",
                                        Description = "Creates a new identity group and returns it in the response"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Request",
                                        Description = "When creating a new group the body of the request must contain a JSON serialization of a <span class='code'>Group<</span> data contract"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Response",
                                        Description = "When creating a new group the body of the response will contain a JSON serialization of the new <span class='code'>Group<</span> data contract."
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _groupPath.Value + "/{groupId}",
                        Description = "CRUD operations on a identity group",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns details of the requested group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "PUT",
                                        Description = "Overwrites details of a identity group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "DELETE",
                                        Description = "Overwrites details of a identity group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Path element",
                                        Name = "{groupId}",
                                        Description = "The ID of the group to perform the operation on"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _groupRoleListPath.Value + "/{groupId}",
                        Description = "The list of roles assigned to a group of identities.",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of roles IDs assigned to a group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "POST",
                                        Description = "Adds a list of roles to a group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "DELETE",
                                        Description = "Removes a list of roles from a group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Path element",
                                        Name = "{groupId}",
                                        Description = "The ID of the group to perform the operation on"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _roleListPath.Value,
                        Description = "The list of roles. A role is a job function such as software developer, tester, project manager etc. Each group of identities can be assigned to one or more roles",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of roles"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "POST",
                                        Description = "Creates a new role and returns it in the response"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Request",
                                        Description = "When creating a new role the body of the request must contain a JSON serialization of a <span class='code'>Role<</span> data contract"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Response",
                                        Description = "When creating a new role the body of the response will contain a JSON serialization of the new <span class='code'>Role<</span> data contract."
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _rolePath.Value + "/{roleId}",
                        Description = "CRUD operations on a role",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns details of the requested role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "PUT",
                                        Description = "Overwrites details of a role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "DELETE",
                                        Description = "Overwrites details of a role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Path element",
                                        Name = "{roleId}",
                                        Description = "The ID of the role to perform the operation on"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _rolePermissionListPath.Value + "/{roleId}",
                        Description = "The list of permissions assigned to a role.",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of permission IDs assigned to a role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "POST",
                                        Description = "Adds a list of permissions to a role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "DELETE",
                                        Description = "Removes a list of permissions from a role"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Path element",
                                        Name = "{roleId}",
                                        Description = "The ID of the role to perform the operation on"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _permissionListPath.Value,
                        Description = "The list of permissions. A permission is something the software will test for before processing a request, for example permission to 'cancel an order'. Each role can grant one or more permissions to the identities in that role.",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of permissions"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "POST",
                                        Description = "Creates a new permission and returns it in the response"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Request",
                                        Description = "When creating a new permission the body of the request must contain a JSON serialization of a <span class='code'>Permission<</span> data contract"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Body",
                                        Name = "Response",
                                        Description = "When creating a new permission the body of the response will contain a JSON serialization of the new <span class='code'>Permission<</span> data contract."
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _rolePath.Value + "/{permissionId}",
                        Description = "CRUD operations on a permission",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns details of the requested permission"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "PUT",
                                        Description = "Overwrites details of a permission"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "DELETE",
                                        Description = "Overwrites details of a permission"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Path element",
                                        Name = "{permissionId}",
                                        Description = "The ID of the permission to perform the operation on"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _searchIdentityListPath.Value,
                        Description = "Search for an identity based on a search phrase",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns a list of identities matching the search text"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Parameter",
                                        Name = "query",
                                        Description = "The text that was entered to find matching identities"
                                    }
                                }
                    });

                documentation.Add(
                    new EndpointDocumentation
                    {
                        RelativePath = _identityGroupPath.Value,
                        Description = "Get and update the group that an identity belongs to",
                        Attributes = new List<IEndpointAttributeDocumentation>
                                {
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "GET",
                                        Description = "Returns the id of the group that the identity is assigned to"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Method",
                                        Name = "PUT",
                                        Description = "Assigns the identity to a different group"
                                    },
                                    new EndpointAttributeDocumentation
                                    {
                                        Type = "Parameter",
                                        Name = "identity",
                                        Description = "The identity to get/modify"
                                    }
                                }
                    });

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
            get { return "Provides a REST API for managing identity groups, roles and permissionn"; }
        }

        string ISelfDocumenting.ShortDescription
        {
            get { return "Provides a REST API for managing identity groups, roles and permissionn"; }
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
    }
}
