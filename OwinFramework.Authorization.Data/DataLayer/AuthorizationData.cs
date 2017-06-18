using System;
using System.Collections.Generic;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.Authorization.Data.Interfaces;

namespace OwinFramework.Authorization.Data.DataLayer
{
    internal class AuthorizationData: IAuthorizationData
    {
        public IEnumerable<Group> GetGroups(Func<Group, bool> filterFunction = null)
        {
        }

        public IEnumerable<Role> GetRoles(Func<Role, bool> filterFunction = null)
        {
        }

        public IEnumerable<Permission> GetPermissions(Func<Permission, bool> filterFunction = null)
        {
        }

        public Group NewGroup(Group group)
        {
        }

        public Role NewRole(Role role)
        {
        }

        public Permission NewPermission(Permission permission)
        {
        }

        public Group UpdateGroup(Group group)
        {
        }

        public Role UpdateRole(Role role)
        {
        }

        public Permission UpdatePermission(Permission permission)
        {
        }

        public void DeleteGroup(long groupToDelete, long reassignUsersTo)
        {
        }

        public void DeleteRole(long roleToDelete)
        {
        }

        public void DeletePermission(long permissionToDelete)
        {
        }

        public IEnumerable<Role> GetGroupRoles(long groupId)
        {
        }

        public IEnumerable<Permission> GetRolePermissions(long roleId)
        {
        }

        public Group GetUserGroup(string userId)
        {
        }

        public IEnumerable<Role> GetUserRoles(string userId)
        {
        }

        public IEnumerable<Permission> GetUserPermissions(string userId)
        {
        }

        public Group ChangeUserGroup(string userId, long groupId)
        {
        }

        public void AddRoleToGroup(long roleId, long groupId)
        {
        }

        public void AddPermissionToRole(long permissionId, long groupId)
        {
        }

        public void RemoveRoleFromGroup(long roleId, long groupId)
        {
        }

        public void RemovePermissionFromRole(long permissionId, long groupId)
        {
        }
    }
}
