using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    public class Group
    {
        [Mapping("groupId")]
        public long Id { get; set; }

        [Mapping("groupCodeName")]
        public string CodeName { get; set; }

        [Mapping("groupDisplayName")]
        public string DisplayName { get; set; }

        [Mapping("groupDescription")]
        public string Description { get; set; }
    }
}
