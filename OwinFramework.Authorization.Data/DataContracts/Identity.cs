using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    internal class IdentityGroup
    {
        public long GroupId { get; set; }
        public string CodeName { get; set; }
        public IdentityRole[] IdentityRoles;
        public IdentityPermission[] IdentityPermissions;
    }

    internal struct IdentityRole
    {
        public long RoleId { get; set; }
        public string CodeName { get; set; }
    }

    internal struct IdentityPermission
    {
        public long PermissionId { get; set; }
        public string CodeName { get; set; }
        public string Resource { get; set; }
    }
}
