using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Data.DataContracts
{
    public class Group
    {
        [Mapping("groupId")]
        public long Id { get; set; }

        [Mapping("groupName")]
        public string Name { get; set; }

        [Mapping("groupDescription")]
        public string Description { get; set; }
    }
}
