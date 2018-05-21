namespace OwinFramework.Authorization.Prius.Poco
{
    internal struct IdentityRole
    {
        public long RoleId { get; set; }
        public string CodeName { get; set; }
        public IdentityPermission[] IdentityPermissions;
    }
}
