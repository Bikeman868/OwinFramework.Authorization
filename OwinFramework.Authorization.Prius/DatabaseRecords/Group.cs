using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Prius.DatabaseRecords
{
    internal interface IGroup
    {
        [Mapping("groupId")]
        long Id { get; set; }

        [Mapping("groupCodeName")]
        string CodeName { get; set; }

        [Mapping("groupDisplayName")]
        string DisplayName { get; set; }

        [Mapping("groupDescription")]
        string Description { get; set; }
    }

    internal class Group : Core.DataContracts.Group, IGroup
    {
    }
}
