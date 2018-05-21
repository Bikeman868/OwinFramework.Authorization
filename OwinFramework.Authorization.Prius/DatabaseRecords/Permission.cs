using Prius.Contracts.Attributes;

namespace OwinFramework.Authorization.Prius.DatabaseRecords
{
    internal interface IPermission
    {
        [Mapping("permissionId")]
        long Id { get; set; }

        [Mapping("permissionCodeName")]
        string CodeName { get; set; }

        [Mapping("permissionResource")]
        string Resource { get; set; }

        [Mapping("permissionDisplayName")]
        string DisplayName { get; set; }

        [Mapping("permissionDescription")]
        string Description { get; set; }
    }

    internal class Permission : Core.DataContracts.Permission, IPermission
    {
    }
}
