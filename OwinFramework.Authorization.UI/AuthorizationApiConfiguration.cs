using System;

namespace OwinFramework.Authorization.UI
{
    [Serializable]
    internal class AuthorizationApiConfiguration
    {
        public string DocumentationRootUrl { get; set; }
        public string ApiRootUrl { get; set; }

        public string PermissionToCallApi { get; set; }
        public string PermissionToEditPermissions { get; set; }
        public string PermissionToEditRoles { get; set; }
        public string PermissionToEditGroups { get; set; }
        public string PermissionToAssignPermissionToRole { get; set; }
        public string PermissionToAssignRoleToGroup { get; set; }
        public string PermissionToAssignUserToGroup { get; set; }

        public AuthorizationApiConfiguration()
        {
            DocumentationRootUrl = "/owin/authorizationApi/config";
            ApiRootUrl = "/api/authorization";

            PermissionToCallApi = "auth:api";
            PermissionToEditPermissions = "auth:permission.edit";
            PermissionToEditRoles = "auth:role.edit";
            PermissionToEditGroups = "auth:group.edit";
            PermissionToAssignPermissionToRole = "auth:permission.assign";
            PermissionToAssignRoleToGroup = "auth:role.assign";
            PermissionToAssignUserToGroup = "auth:group.assign";
        }
    }
}
