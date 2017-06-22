using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    public class Permission
    {
        [Mapping("permissionId")]
        public long Id { get; set; }

        [Mapping("permissionCodeName")]
        public string CodeName { get; set; }

        [Mapping("permissionResource")]
        public string Resource { get; set; }

        [Mapping("permissionDisplayName")]
        public string DisplayName { get; set; }

        [Mapping("permissionDescription")]
        public string Description { get; set; }
    }
}
