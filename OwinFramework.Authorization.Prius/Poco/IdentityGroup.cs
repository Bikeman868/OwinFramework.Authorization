namespace OwinFramework.Authorization.Prius.Poco
{
    internal class IdentityGroup
    {
        public long GroupId { get; set; }
        public string CodeName { get; set; }
        public IdentityRole[] IdentityRoles;
        public IdentityPermission[] IdentityPermissions;
    }
}
