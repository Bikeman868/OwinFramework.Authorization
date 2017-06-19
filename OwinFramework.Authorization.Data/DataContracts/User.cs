using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    public class UserGroup
    {
        public long GroupId { get; set; }
        public UserRole[] UserRoles;
        public UserPermission[] UserPermissions;
    }

    public struct UserRole
    {
        public long RoleId { get; set; }
        public string CodeName { get; set; }
    }

    public struct UserPermission
    {
        public long PermissionId { get; set; }
        public string CodeName { get; set; }
    }
}
