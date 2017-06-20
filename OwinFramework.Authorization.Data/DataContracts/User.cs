using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    internal class UserGroup
    {
        public long GroupId { get; set; }
        public UserRole[] UserRoles;
        public UserPermission[] UserPermissions;
    }

    internal struct UserRole
    {
        public long RoleId { get; set; }
        public string CodeName { get; set; }
    }

    internal struct UserPermission
    {
        public long PermissionId { get; set; }
        public string CodeName { get; set; }
    }
}
