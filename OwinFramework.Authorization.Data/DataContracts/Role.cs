using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    public class Role
    {
        [Mapping("roleId")]
        public long Id { get; set; }

        [Mapping("roleCodeName")]
        public string CodeName { get; set; }

        [Mapping("roleDisplayName")]
        public string DisplayName { get; set; }

        [Mapping("roleDescription")]
        public string Description { get; set; }
    }
}
