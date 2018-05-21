namespace OwinFramework.Authorization.Core.DataContracts
{
    /// <summary>
    /// The database representation of a role. Permissions are grouped into
    /// roles, then these roles are assigned to groups to give them a
    /// set of permissions.
    /// </summary>
    public class Role
    {
        /// <summary>
        /// Database primary key value for this role
        /// </summary>
        public long Id { get; set; }

        /// <summary>
        /// An internal name for this role that is referred to in the 
        /// source code of the application and should not be changed in
        /// the database
        /// </summary>
        public string CodeName { get; set; }

        /// <summary>
        /// The name of this role as shown in the UI
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// A description of this role. This description is shown in the
        /// UI to help administrators to decide if they should assign this
        /// role to a particular group of identities.
        /// </summary>
        public string Description { get; set; }
    }
}
