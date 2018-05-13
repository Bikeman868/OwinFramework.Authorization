using System;
using System.Collections.Generic;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.InterfacesV1.Middleware;

namespace OwinFramework.Authorization.Data.Interfaces
{
    public interface IAuthorizationData
    {
        /// <summary>
        /// Searches for the authorization data from the result of running
        /// IIdentification middleware
        /// </summary>
        void GetIdentity(
            IIdentification identification,
            out Group group, 
            out List<string> roles,
            out List<string> permissions);

        /// <summary>
        /// Returns a list of all groups with optional filtering
        /// </summary>
        IList<Group> GetGroups(Func<Group, bool> filterFunction = null);

        /// <summary>
        /// Returns a list of all roles with optional filtering
        /// </summary>
        IList<Role> GetRoles(Func<Role, bool> filterFunction = null);

        /// <summary>
        /// Returns a list of all permissions with optional filtering
        /// </summary>
        IList<Permission> GetPermissions(Func<Permission, bool> filterFunction = null);

        /// <summary>
        /// Returns a specific group by ID
        /// </summary>
        Group GetGroup(long groupId);

        /// <summary>
        /// Returns a specific role by ID
        /// </summary>
        Role GetRole(long roleId);

        /// <summary>
        /// Returns a specific permission by ID
        /// </summary>
        Permission GetPermission(long permissionId);

        /// <summary>
        /// Returns a specific group by name
        /// </summary>
        Group GetGroup(string groupCodeName);

        /// <summary>
        /// Returns a specific role by name
        /// </summary>
        Role GetRole(string roleCodeName);

        /// <summary>
        /// Returns a specific permission by name
        /// </summary>
        Permission GetPermission(string permissionCodeName);

        /// <summary>
        /// Throws an exception if this is not a valid group definition
        /// </summary>
        void Validate(Group group);

        /// <summary>
        /// Throws an exception if this is not a valid role definition
        /// </summary>
        void Validate(Role role);

        /// <summary>
        /// Throws an exception if this is not a valid permission definition
        /// </summary>
        void Validate(Permission permission);

        /// <summary>
        /// Creates a new group. Throws an exception if the group already exists
        /// </summary>
        Group NewGroup(Group group);

        /// <summary>
        /// Creates a new role. Throws an exception if the role already exists
        /// </summary>
        Role NewRole(Role role);

        /// <summary>
        /// Creates a new permission. Throws an exception if the permission already exists
        /// </summary>
        Permission NewPermission(Permission permission);

        /// <summary>
        /// Creates a permission if the permission does not excist, or returns the
        /// existing permission definition. Applications can use this at startup to
        /// ensure that the permissions they check for exist in the database.
        /// </summary>
        Permission EnsurePermission(Permission permission);

        /// <summary>
        /// Updates the details of an existing group. Throws an exception if the
        /// details are invalid or the group does not exist
        /// </summary>
        Group UpdateGroup(Group group);

        /// <summary>
        /// Updates the details of an existing role. Throws an exception if the
        /// details are invalid or the role does not exist
        /// </summary>
        Role UpdateRole(Role role);

        /// <summary>
        /// Updates the details of an existing permission. Throws an exception if the
        /// details are invalid or the permission does not exist
        /// </summary>
        Permission UpdatePermission(Permission permission);

        /// <summary>
        /// Moves all of the users in a group to a different group then deletes
        /// the group.
        /// </summary>
        void DeleteGroup(long groupToDelete, long reassignIdentitiesTo);

        /// <summary>
        /// Deletes a role from the database
        /// </summary>
        void DeleteRole(long roleToDelete);

        /// <summary>
        /// Deletes a permission from the database
        /// </summary>
        void DeletePermission(long permissionToDelete);

        /// <summary>
        /// Gets a list of the roles assigned to a group
        /// </summary>
        IList<Role> GetGroupRoles(long groupId);

        /// <summary>
        /// Gets a list of the permissions assigned to a role
        /// </summary>
        IList<Permission> GetRolePermissions(long roleId);

        /// <summary>
        /// Gets a list of all group/role assignments in the database
        /// </summary>
        IList<Tuple<long, long>> GetAllGroupRoles();

        /// <summary>
        /// Gets a list of all role/permission assignments in the database
        /// </summary>
        IList<Tuple<long, long>> GetAllRolePermissions();

        /// <summary>
        /// Finds the id of the group that an identity belongs to
        /// </summary>
        long? GetIdentityGroupId(string identity);

        /// <summary>
        /// Finds the id of the group that an identity belongs to
        /// </summary>
        long? GetGroupId(IIdentification identification);

        /// <summary>
        /// Retrieves details about the group that an identity belongs to
        /// </summary>
        Group GetGroup(IIdentification identification);

        /// <summary>
        /// Retrieves a list of the roles assigned to an identity
        /// </summary>
        IList<Role> GetRoles(IIdentification identification);

        /// <summary>
        /// Retrieves a list of permissions assigned to an identity. If the identity
        /// has the same permission assigned to them multiple times (by different roles)
        /// then this permission will only be in the list once.
        /// </summary>
        IList<Permission> GetPermissions(IIdentification identification);

        /// <summary>
        /// Checks if an identity has the specified role. This is an unusual thing
        /// to check for and is only included here for the sake of completeness
        /// </summary>
        bool IsInRole(IIdentification identification, string roleCodeName);

        /// <summary>
        /// Checks if an identity has a specified permission on the specified resource
        /// </summary>
        /// <param name="identification">The identity to be checked</param>
        /// <param name="permissionCodeName">The name of the permission to check</param>
        /// <param name="resourceName">The path to the resource or null if not applicable.
        /// For example an identity might have permission to reset passwords but only
        /// whan it is their own password, or they might have permission to reset any password</param>
        bool HasPermission(IIdentification identification, string permissionCodeName, string resourceName);

        /// <summary>
        /// Returns the ID of the group to use for permissions for a given identity. This
        /// method is different from GetGroupId because GetGroupId returns the group 
        /// specifically assigned to the identity, whereas this method will return one of the 
        /// built-in groups for anonymous or unassigned identities.
        /// </summary>
        long? FindGroup(IIdentification identification);

        /// <summary>
        /// Moves a user to a new group or assigns them to a group if they are not currently
        /// assigned.
        /// </summary>
        Group ChangeGroup(IIdentification identification, long? groupId);

        /// <summary>
        /// Adds a role to a group granting all of the users in that group new permissions
        /// </summary>
        void AddRoleToGroup(long roleId, long groupId);

        /// <summary>
        /// Adds a new permission to a role granting that permission to all groups of
        /// users that have that role.
        /// </summary>
        void AddPermissionToRole(long permissionId, long roleId);

        /// <summary>
        /// Removes a role from a group, revoking permissions that are not included in
        /// any other role assigned to the group
        /// </summary>
        void RemoveRoleFromGroup(long roleId, long groupId);

        /// <summary>
        /// Removes a permission from a role.
        /// </summary>
        void RemovePermissionFromRole(long permissionId, long roleId);
    }
}
