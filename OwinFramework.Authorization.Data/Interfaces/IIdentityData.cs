using System;
using System.Collections.Generic;
using OwinFramework.Authorization.Data.DataContracts;
using OwinFramework.InterfacesV1.Middleware;

namespace OwinFramework.Authorization.Data.Interfaces
{
    public interface IIdentityData
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
        /// Creates a permission if the permission does not excist, or returns the
        /// existing permission definition. Applications can use this at startup to
        /// ensure that the permissions they check for exist in the database.
        /// </summary>
        Permission EnsurePermission(Permission permission);

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
    }
}
