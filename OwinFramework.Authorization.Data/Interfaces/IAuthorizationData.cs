using System;
using System.Collections.Generic;
using OwinFramework.Authorization.Data.DataContracts;

namespace OwinFramework.Authorization.Data.Interfaces
{
    public interface IAuthorizationData
    {
        IEnumerable<Group> GetGroups(Func<Group, bool> filterFunction = null);
        IEnumerable<Role> GetRoles(Func<Role, bool> filterFunction = null);
        IEnumerable<Permission> GetPermissions(Func<Permission, bool> filterFunction = null);

        Group NewGroup(Group group);
        Role NewRole(Role role);
        Permission NewPermission(Permission permission);

        Group UpdateGroup(Group group);
        Role UpdateRole(Role role);
        Permission UpdatePermission(Permission permission);

        void DeleteGroup(long groupToDelete, long reassignIdentitiesTo);
        void DeleteRole(long roleToDelete);
        void DeletePermission(long permissionToDelete);

        IEnumerable<Role> GetGroupRoles(long groupId);
        IEnumerable<Permission> GetRolePermissions(long roleId);

        long? GetIdentityGroupId(string identity);
        Group GetIdentityGroup(string identity);
        IEnumerable<Role> GetIdentityRoles(string identity);
        IEnumerable<Permission> GetIdentityPermissions(string identity);

        bool IdentityIsInRole(string identity, string roleCodeName);
        bool IdentityHasPermission(string identity, string permissionCodeName, string resourceName);

        Group ChangeIdentityGroup(string identity, long groupId);

        void AddRoleToGroup(long roleId, long groupId);
        void AddPermissionToRole(long permissionId, long roleId);

        void RemoveRoleFromGroup(long roleId, long groupId);
        void RemovePermissionFromRole(long permissionId, long roleId);
    }
}
