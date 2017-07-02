using System;
using System.Collections.Generic;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.InterfacesV1.Middleware;

namespace OwinFramework.Authorization.Data.Interfaces
{
    public interface IAuthorizationData
    {
        void GetIdentity(
            IIdentification identification, 
            out string group, 
            out List<string> roles,
            out List<string> permissions);

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

        long? GetGroupId(IIdentification identification);
        Group GetGroup(IIdentification identification);
        IEnumerable<Role> GetRoles(IIdentification identification);
        IEnumerable<Permission> GetPermissions(IIdentification identification);

        bool IsInRole(IIdentification identification, string roleCodeName);
        bool HasPermission(IIdentification identification, string permissionCodeName, string resourceName);

        Group ChangeGroup(IIdentification identification, long groupId);

        void AddRoleToGroup(long roleId, long groupId);
        void AddPermissionToRole(long permissionId, long roleId);

        void RemoveRoleFromGroup(long roleId, long groupId);
        void RemovePermissionFromRole(long permissionId, long roleId);
    }
}
