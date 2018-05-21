namespace OwinFramework.Authorization.Prius.Poco
{
    internal struct IdentityPermission
    {
        public long PermissionId { get; set; }
        public string CodeName { get; set; }
        public string Resource { get; set; }
    }
}
