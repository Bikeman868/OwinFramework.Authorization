using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Prius.DatabaseRecords
{
    internal interface IRole
    {
        [Mapping("roleId")]
        long Id { get; set; }

        [Mapping("roleCodeName")]
        string CodeName { get; set; }

        [Mapping("roleDisplayName")]
        string DisplayName { get; set; }

        [Mapping("roleDescription")]
        string Description { get; set; }
    }

    internal class Role : Core.DataContracts.Role, IRole
    {
    }
}
