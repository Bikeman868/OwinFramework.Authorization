﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Microsoft.Owin;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using OwinFramework.Authorization.Data.DataContracts;
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
        ISelfDocumenting,
        ITraceable
    {
        private readonly IList<IDependency> _dependencies = new List<IDependency>();
        IList<IDependency> IMiddleware.Dependencies { get { return _dependencies; } }
        string IMiddleware.Name { get; set; }
        public Action<IOwinContext, Func<string>> Trace { get; set; }

        private readonly IAuthorizationData _authorizationData;

        private PathString _documentationPath;

        private PathString _validateGroupPath;
        private PathString _validateRolePath;
        private PathString _validatePermissionPath;

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

            ConfigurationChanged(new AuthorizationApiConfiguration());
        }

        #region Request routing and permissions

        Task IRoutingProcessor.RouteRequest(IOwinContext context, Func<Task> next)
        {
            var apiContext = new ApiContext();
            context.SetFeature(apiContext);

            var upstreamIdentification = context.GetFeature<IUpstreamIdentification>();
            var upstreamAuthorization = context.GetFeature<IUpstreamAuthorization>();

            if (!string.IsNullOrEmpty(_configuration.PermissionToCallApi))
            {
                if (upstreamIdentification != null)
                    upstreamIdentification.AllowAnonymous = false;

                if (upstreamAuthorization != null)
                    upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToCallApi);
            }

            var path = context.Request.Path;
            var method = context.Request.Method;

            if (method == "GET")
            {
                if (path.Equals(_documentationPath))
                    apiContext.Handler = DocumentConfiguration;
                else if (path.StartsWithSegments(_groupRoleListPath))
                    apiContext.Handler = GetGroupRoleListHandler;
                else if (path.StartsWithSegments(_groupPath))
                    apiContext.Handler = GetGroupHandler;
                else if (path.StartsWithSegments(_groupListPath))
                    apiContext.Handler = GetGroupListHandler;
                else if (path.StartsWithSegments(_rolePermissionListPath))
                    apiContext.Handler = GetRolePermissionListHandler;
                else if (path.StartsWithSegments(_rolePath))
                    apiContext.Handler = GetRoleHandler;
                else if (path.StartsWithSegments(_roleListPath))
                    apiContext.Handler = GetRoleListHandler;
                else if (path.StartsWithSegments(_permissionPath))
                    apiContext.Handler = GetPermissionHandler;
                else if (path.StartsWithSegments(_permissionListPath))
                    apiContext.Handler = GetPermissionListHandler;
            }
            else if (context.Request.Method == "POST")
            {
                if (path.StartsWithSegments(_groupListPath))
                {
                    apiContext.Handler = NewGroupHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditGroups);
                }
                else if (path.StartsWithSegments(_roleListPath))
                {
                    apiContext.Handler = NewRoleHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditRoles);
                }
                else if (path.StartsWithSegments(_permissionListPath))
                {
                    apiContext.Handler = NewPermissionHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditPermissions);
                }
                else if (path.StartsWithSegments(_validateGroupPath))
                {
                    apiContext.Handler = ValidateGroupHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditGroups);
                }
                else if (path.StartsWithSegments(_validateRolePath))
                {
                    apiContext.Handler = ValidateRoleHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditRoles);
                }
                else if (path.StartsWithSegments(_validatePermissionPath))
                {
                    apiContext.Handler = ValidatePermissionHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditPermissions);
                }
            }
            else if (context.Request.Method == "PUT")
            {
                if (path.StartsWithSegments(_groupPath))
                {
                    apiContext.Handler = UpdateGroupHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditGroups);
                }
                else if (path.StartsWithSegments(_rolePath))
                {
                    apiContext.Handler = UpdateRoleHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditRoles);
                }
                else if (path.StartsWithSegments(_permissionPath))
                {
                    apiContext.Handler = UpdatePermissionHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditPermissions);
                }
            }
            else if (context.Request.Method == "DELETE")
            {
                if (path.StartsWithSegments(_groupPath))
                {
                    apiContext.Handler = DeleteGroupHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditGroups);
                }
                else if (path.StartsWithSegments(_rolePath))
                {
                    apiContext.Handler = DeleteRoleHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditRoles);
                }
                else if (path.StartsWithSegments(_permissionPath))
                {
                    apiContext.Handler = DeletePermissionHandler;
                    if (upstreamAuthorization != null)
                        upstreamAuthorization.AddRequiredPermission(_configuration.PermissionToEditPermissions);
                }
            }
            return next();
        }

        Task IMiddleware.Invoke(IOwinContext context, Func<Task> next)
        {
            var apiContext = context.GetFeature<ApiContext>();
            if (apiContext == null || apiContext.Handler == null)
                return next();

            try
            {
                return apiContext.Handler(context);
            }
            catch(Exception ex)
            {
                var result = new ApiResponse
                {
                    Result = ApiResult.FatalError,
                    ErrorMessage = ex.Message
                };
                return Json(context, result);
            }
        }

        private Task Json<T>(IOwinContext context, T result) where T : ApiResponse
        {
            context.Response.ContentType = "application/json";
            return context.Response.WriteAsync(JsonConvert.SerializeObject(result));
        }

        #endregion

        #region Group related handlers

        private Task GetGroupHandler(IOwinContext context)
        {
            var response = new GetGroupResponse();

            long id;
            if (!ParseIdFromPath(context, _groupPath, response, "group", out id))
                return Json(context, response);

            var group = _authorizationData.GetGroup(id);
            if (group == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "There is no group with id " + id;
            }
            else
            {
                response.Group = new GroupDto
                {
                    Id = group.Id,
                    CodeName = group.CodeName,
                    DisplayName = group.DisplayName,
                    Description = group.Description
                };
            }

            return Json(context, response);
        }

        private Task GetGroupListHandler(IOwinContext context)
        {
            var result = new GetGroupListResponse
            {
                Groups = _authorizationData.GetGroups()
                .Select(g => new GroupDto
                {
                    Id = g.Id,
                    CodeName = g.CodeName,
                    DisplayName = g.DisplayName,
                    Description = g.Description
                })
                .ToList()
            };

            return Json(context, result);
        }

        private Task GetGroupRoleListHandler(IOwinContext context)
        {
            var result = new GetRelationListResponse();

            long? groupId = null;
            var residualPath = context.Request.Path.Value.Substring(_groupRoleListPath.Value.Length);
            if (residualPath.Length > 0)
            {
                if (residualPath.StartsWith("/")) residualPath = residualPath.Substring(1);

                long id;
                if (!long.TryParse(residualPath, out id))
                {
                    result.Result = ApiResult.BadRequest;
                    result.ErrorMessage = "The group ID in the URL must be a valid integer";
                    return Json(context, result);
                }
                groupId = id;
            }

            if (groupId.HasValue)
            {
                result.Relations = _authorizationData.GetGroupRoles(groupId.Value)
                    .Select(r => new RelationDto{ParentId = groupId.Value, ChildId = r.Id })
                    .ToList();
            }
            else
            {
                result.Relations = _authorizationData.GetAllGroupRoles()
                    .Select(gr => new RelationDto { ParentId = gr.Item1, ChildId = gr.Item2 })
                    .ToList();
            };

            return Json(context, result);
        }

        private Task ValidateGroupHandler(IOwinContext context)
        {
            var result = new ValidationResponse();

            try
            {
                var groupDto = GetBody<GroupDto>(context);
                var group = new Group
                {
                    Id = groupDto.Id,
                    CodeName = groupDto.CodeName,
                    DisplayName = groupDto.DisplayName,
                    Description = groupDto.Description
                };
                _authorizationData.Validate(group);
            }
            catch (Exception ex)
            {
                result.Result = ApiResult.FatalError;
                result.ErrorMessage = ex.Message;
            }

            return Json(context, result);
        }

        private Task NewGroupHandler(IOwinContext context)
        {
            var response = new NewRecordResponse();
            var groupDto = GetBody<GroupDto>(context);

            var group = new Group
            {
                CodeName = groupDto.CodeName,
                DisplayName = groupDto.DisplayName,
                Description = groupDto.Description
            };

            try
            {
                group = _authorizationData.NewGroup(group);
                response.Id = group.Id;
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage =
                    "Failed to add group " + group.CodeName +
                    " to the database. " + ex.Message;
            }

            return Json(context, response);
        }

        private Task UpdateGroupHandler(IOwinContext context)
        {
            var response = new ApiResponse();
            var groupDto = GetBody<GroupDto>(context);

            var group = _authorizationData.GetGroup(groupDto.Id);
            if (group == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "No group found with id " + groupDto.Id;
            }
            else
            {
                group.CodeName = groupDto.CodeName;
                group.DisplayName = groupDto.DisplayName;
                group.Description = groupDto.Description;

                try
                {
                    _authorizationData.UpdateGroup(group);
                }
                catch (Exception ex)
                {
                    response.Result = ApiResult.FatalError;
                    response.ErrorMessage =
                        "Failed to update group " + group.Id +
                        " in the database. " + ex.Message;
                }
            }

            return Json(context, response);
        }

        private Task DeleteGroupHandler(IOwinContext context)
        {
            var response = new ApiResponse();

            long id;
            if (!ParseIdFromPath(context, _groupPath, response, "group", out id))
                return Json(context, response);

            var replacementParam = context.Request.Query["replacement"];
            if (string.IsNullOrEmpty(replacementParam))
            {
                response.Result = ApiResult.BadRequest;
                response.ErrorMessage = "When deleting a group users in that group must be reassigned to a different group";
                return Json(context, response);
            }

            long replacementId;
            if (!long.TryParse(replacementParam, out replacementId))
            {
                response.Result = ApiResult.BadRequest;
                response.ErrorMessage = "The replacement group id must be a valid integer";
                return Json(context, response);
            }

            try
            {
                _authorizationData.DeleteGroup(id, replacementId);
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage =
                    "Failed to delete group " + id +
                    " from the database. " + ex.Message;
            }

            return Json(context, response);
        }

        #endregion

        #region Role related handlers

        private Task GetRoleHandler(IOwinContext context)
        {
            var response = new GetRoleResponse();

            long id;
            if (!ParseIdFromPath(context, _rolePath, response, "role", out id))
                return Json(context, response);

            var role = _authorizationData.GetRole(id);
            if (role == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "There is no role with id " + id;
            }
            else
            {
                response.Role = new RoleDto
                {
                    Id = role.Id,
                    CodeName = role.CodeName,
                    DisplayName = role.DisplayName,
                    Description = role.Description
                };
            }

            return Json(context, response);
        }

        private Task GetRoleListHandler(IOwinContext context)
        {
            var result = new GetRoleListResponse
            {
                Roles = _authorizationData.GetRoles()
                .Select(r => new RoleDto
                {
                    Id = r.Id,
                    CodeName = r.CodeName,
                    DisplayName = r.DisplayName,
                    Description = r.Description
                })
                .ToList()
            };

            return Json(context, result);
        }

        private Task GetRolePermissionListHandler(IOwinContext context)
        {
            var result = new GetRelationListResponse();

            long? roleId = null;
            var residualPath = context.Request.Path.Value.Substring(_rolePermissionListPath.Value.Length);
            if (residualPath.Length > 0)
            {
                if (residualPath.StartsWith("/")) residualPath = residualPath.Substring(1);

                long id;
                if (!long.TryParse(residualPath, out id))
                {
                    result.Result = ApiResult.BadRequest;
                    result.ErrorMessage = "The role ID in the URL must be a valid integer";
                    return Json(context, result);
                }
                roleId = id;
            }

            if (roleId.HasValue)
            {
                result.Relations = _authorizationData.GetRolePermissions(roleId.Value)
                    .Select(p => new RelationDto { ParentId = roleId.Value, ChildId = p.Id })
                    .ToList();
            }
            else
            {
                result.Relations = _authorizationData.GetAllRolePermissions()
                    .Select(rp => new RelationDto { ParentId = rp.Item1, ChildId = rp.Item2 })
                    .ToList();
            };

            return Json(context, result);
        }

        private Task ValidateRoleHandler(IOwinContext context)
        {
            var result = new ValidationResponse();

            try
            {
                var roleDto = GetBody<RoleDto>(context);
                var role = new Role
                {
                    Id = roleDto.Id,
                    CodeName = roleDto.CodeName,
                    DisplayName = roleDto.DisplayName,
                    Description = roleDto.Description
                };
                _authorizationData.Validate(role);
            }
            catch (Exception ex)
            {
                result.Result = ApiResult.FatalError;
                result.ErrorMessage = ex.Message;
            }

            return Json(context, result);
        }

        private Task NewRoleHandler(IOwinContext context)
        {
            var response = new NewRecordResponse();
            var roleDto = GetBody<RoleDto>(context);

            var role = new Role
            {
                CodeName = roleDto.CodeName,
                DisplayName = roleDto.DisplayName,
                Description = roleDto.Description
            };

            try
            {
                role = _authorizationData.NewRole(role);
                response.Id = role.Id;
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage =
                    "Failed to add role " + role.CodeName +
                    " to the database. " + ex.Message;
            }

            return Json(context, response);
        }

        private Task UpdateRoleHandler(IOwinContext context)
        {
            var response = new ApiResponse();
            var roleDto = GetBody<RoleDto>(context);

            var role = _authorizationData.GetRole(roleDto.Id);
            if (role == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "No role found with id " + roleDto.Id;
            }
            else
            {
                role.CodeName = roleDto.CodeName;
                role.DisplayName = roleDto.DisplayName;
                role.Description = roleDto.Description;

                try
                {
                    _authorizationData.UpdateRole(role);
                }
                catch (Exception ex)
                {
                    response.Result = ApiResult.FatalError;
                    response.ErrorMessage =
                        "Failed to update role " + role.Id +
                        " in the database. " + ex.Message;
                }
            }

            return Json(context, response);
        }

        private Task DeleteRoleHandler(IOwinContext context)
        {
            var response = new ApiResponse();

            long id;
            if (!ParseIdFromPath(context, _rolePath, response, "role", out id))
                return Json(context, response);

            try
            {
                _authorizationData.DeleteRole(id);
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage =
                    "Failed to delete role " + id +
                    " from the database. " + ex.Message;
            }

            return Json(context, response);
        }

        #endregion

        #region Permission related handlers

        private Task GetPermissionHandler(IOwinContext context)
        {
            var response = new GetPermissionResponse();

            long id;
            if (!ParseIdFromPath(context, _permissionPath, response, "permission", out id))
                return Json(context, response);

            var permission = _authorizationData.GetPermission(id);
            if (permission == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "There is no permission with id " + id;
            }
            else
            {
                response.Permission = new PermissionDto
                {
                    Id = permission.Id,
                    CodeName = permission.CodeName,
                    DisplayName = permission.DisplayName,
                    Description = permission.Description,
                    Resource = permission.Resource
                };
            }

            return Json(context, response);
        }

        private Task GetPermissionListHandler(IOwinContext context)
        {
            var response = new GetPermissionListResponse
            {
                Permissions = _authorizationData.GetPermissions()
                .Select(p => new PermissionDto
                {
                    Id = p.Id,
                    CodeName = p.CodeName,
                    Resource = p.Resource,
                    DisplayName = p.DisplayName,
                    Description = p.Description
                })
                .ToList()
            };

            return Json(context, response);
        }

        private Task ValidatePermissionHandler(IOwinContext context)
        {
            var response = new ValidationResponse();

            try
            {
                var permissionDto = GetBody<PermissionDto>(context);
                var permission = new Permission
                {
                    Id = permissionDto.Id,
                    CodeName = permissionDto.CodeName,
                    DisplayName = permissionDto.DisplayName,
                    Description = permissionDto.Description,
                    Resource = permissionDto.Resource
                };
                _authorizationData.Validate(permission);
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage = ex.Message;
            }

            return Json(context, response);
        }

        private Task NewPermissionHandler(IOwinContext context)
        {
            var response = new NewRecordResponse();
            var permissionDto = GetBody<PermissionDto>(context);

            var permission = new Permission
            {
                CodeName = permissionDto.CodeName,
                DisplayName = permissionDto.DisplayName,
                Description = permissionDto.Description,
                Resource = permissionDto.Resource
            };

            try
            {
                permission = _authorizationData.NewPermission(permission);
                response.Id = permission.Id;
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage = 
                    "Failed to add permission " + permission.CodeName + 
                    " to the database. " + ex.Message;
            }

            return Json(context, response);
        }

        private Task UpdatePermissionHandler(IOwinContext context)
        {
            var response = new ApiResponse();
            var permissionDto = GetBody<PermissionDto>(context);

            var permission = _authorizationData.GetPermission(permissionDto.Id);
            if (permission == null)
            {
                response.Result = ApiResult.NotFound;
                response.ErrorMessage = "No permission found with id " + permissionDto.Id;
            }
            else
            {
                permission.CodeName = permissionDto.CodeName;
                permission.DisplayName = permissionDto.DisplayName;
                permission.Description = permissionDto.Description;
                permission.Resource = permissionDto.Resource;

                try
                {
                    _authorizationData.UpdatePermission(permission);
                }
                catch (Exception ex)
                {
                    response.Result = ApiResult.FatalError;
                    response.ErrorMessage =
                        "Failed to update permission " + permission.Id +
                        " in the database. " + ex.Message;
                }
            }

            return Json(context, response);
        }

        private Task DeletePermissionHandler(IOwinContext context)
        {
            var response = new ApiResponse();

            long id;
            if (!ParseIdFromPath(context, _permissionPath, response, "permission", out id))
                return Json(context, response);

            try
            {
                _authorizationData.DeletePermission(id);
            }
            catch (Exception ex)
            {
                response.Result = ApiResult.FatalError;
                response.ErrorMessage =
                    "Failed to delete permission " + id +
                    " from the database. " + ex.Message;
            }

            return Json(context, response);
        }

        #endregion

        #region Request parsing

        protected T GetBody<T>(IOwinContext context)
        {
            T content;
            try
            {
                string body;
                using (var sr = new StreamReader(context.Request.Body, Encoding.UTF8))
                    body = sr.ReadToEnd();
                content = JsonConvert.DeserializeObject<T>(body);
            }
            catch (Exception ex)
            {
                throw new HttpException((int)HttpStatusCode.BadRequest,
                    "The body of the request could not be deserialized as " +
                    typeof(T).FullName + ". " + ex.Message);
            }
            return content;
        }

        private bool ParseIdFromPath(
            IOwinContext context, 
            PathString basePath, 
            ApiResponse response, 
            string name,
            out long id)
        {
            PathString remainingPath;
            if (context.Request.Path.StartsWithSegments(basePath, out remainingPath) && remainingPath.HasValue)
            {
                if (long.TryParse(remainingPath.Value.Substring(1), out id))
                    return true;

                response.Result = ApiResult.BadRequest;
                response.ErrorMessage = "The id of the " + name + " must be an integer";
            }
            else
            {
                response.Result = ApiResult.BadRequest;
                response.ErrorMessage = "The id of the " + name + " must be passed in the url path";
                id = 0;
            }
            return false;
        }

        #endregion

        #region IConfigurable

        private IDisposable _configurationRegistration;
        private AuthorizationApiConfiguration _configuration = new AuthorizationApiConfiguration();

        void IConfigurable.Configure(IConfiguration configuration, string path)
        {
            _configurationRegistration = configuration.Register(
                path,
                ConfigurationChanged,
                new AuthorizationApiConfiguration());
        }

        private void ConfigurationChanged(AuthorizationApiConfiguration configuration)
        {
            _configuration = configuration;

            var root = string.IsNullOrEmpty(configuration.ApiRootUrl) ? "/" : configuration.ApiRootUrl;
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

            _documentationPath = string.IsNullOrEmpty(configuration.DocumentationRootUrl)
                ? new PathString()
                : new PathString(_configuration.DocumentationRootUrl.ToLower());

            _validateGroupPath = new PathString(root + "validate/group");
            _validateRolePath = new PathString(root + "validate/role");
            _validatePermissionPath = new PathString(root + "validate/permission");
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

        #region Api request context

        private class ApiContext
        {
            public Func<IOwinContext, Task> Handler;
        }

        #endregion

        #region Data contracts

        private enum ApiResult
        {
            Success,
            FatalError,
            TemporaryError,
            SessionExpired,
            AccessDenied,
            NotFound,
            BadRequest
        }

        private class GroupDto
        {
            [JsonProperty("id")]
            public long Id { get; set; }

            [JsonProperty("codeName")]
            public string CodeName { get; set; }

            [JsonProperty("displayName")]
            public string DisplayName { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }
        }

        private class RoleDto
        {
            [JsonProperty("id")]
            public long Id { get; set; }

            [JsonProperty("codeName")]
            public string CodeName { get; set; }

            [JsonProperty("displayName")]
            public string DisplayName { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }
        }

        private class PermissionDto
        {
            [JsonProperty("id")]
            public long Id { get; set; }

            [JsonProperty("codeName")]
            public string CodeName { get; set; }

            [JsonProperty("resource")]
            public string Resource { get; set; }

            [JsonProperty("displayName")]
            public string DisplayName { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }
        }

        private class IdentityDto
        {
            [JsonProperty("identity")]
            public string Identity { get; set; }

            [JsonProperty("claims")]
            public List<ClaimDto> Claims { get; set; }
        }

        private class ClaimDto
        {
            [JsonProperty("name")]
            public string Name { get; set; }

            [JsonProperty("value")]
            public string Value { get; set; }

            [JsonProperty("status")]
            public ClaimStatus Status { get; set; }
        }

        private class RelationDto
        {
            [JsonProperty("parentId")]
            public long ParentId { get; set; }

            [JsonProperty("childId")]
            public long ChildId { get; set; }
        }

        private class ApiResponse
        {
            [JsonConverter(typeof(StringEnumConverter))]
            [JsonProperty("result")]
            public ApiResult Result { get; set; }

            [JsonProperty("error")]
            public string ErrorMessage { get; set; }

            public ApiResponse()
            {
                Result = ApiResult.Success;
            }
        }

        private class NewRecordResponse: ApiResponse
        {
            [JsonProperty("id")]
            public long Id { get; set; }
        }

        private class GetGroupResponse : ApiResponse
        {
            [JsonProperty("group")]
            public GroupDto Group { get; set; }
        }

        private class GetGroupListResponse : ApiResponse
        {
            [JsonProperty("groups")]
            public List<GroupDto> Groups { get; set; }
        }

        private class GetRoleResponse : ApiResponse
        {
            [JsonProperty("role")]
            public RoleDto Role { get; set; }
        }

        private class GetRoleListResponse : ApiResponse
        {
            [JsonProperty("roles")]
            public List<RoleDto> Roles { get; set; }
        }

        private class GetPermissionResponse : ApiResponse
        {
            [JsonProperty("permission")]
            public PermissionDto Permission { get; set; }
        }

        private class GetPermissionListResponse : ApiResponse
        {
            [JsonProperty("permissions")]
            public List<PermissionDto> Permissions { get; set; }
        }

        private class SearchIdentitiesResponse : ApiResponse
        {
            [JsonProperty("identities")]
            public List<IdentityDto> Permissions { get; set; }
        }

        private class ValidationResponse : ApiResponse
        {
        }

        private class GetRelationListResponse: ApiResponse
        {
            [JsonProperty("relations")]
            public List<RelationDto> Relations { get; set; }
        }

        #endregion
    }
}
