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

        void DeleteGroup(long groupToDelete, long reassignUsersTo);
        void DeleteRole(long roleToDelete);
        void DeletePermission(long permissionToDelete);

        IEnumerable<Role> GetGroupRoles(long groupId);
        IEnumerable<Permission> GetRolePermissions(long roleId);

        long? GetUserGroupId(string userId);
        Group GetUserGroup(string userId);
        IEnumerable<Role> GetUserRoles(string userId);
        IEnumerable<Permission> GetUserPermissions(string userId);

        bool UserIsInRole(string userId, string roleCodeName);
        bool UserHasPermission(string userId, string permissionCodeName, string resourceName);

        Group ChangeUserGroup(string userId, long groupId);

        void AddRoleToGroup(long roleId, long groupId);
        void AddPermissionToRole(long permissionId, long roleId);

        void RemoveRoleFromGroup(long roleId, long groupId);
        void RemovePermissionFromRole(long permissionId, long roleId);
    }
}
