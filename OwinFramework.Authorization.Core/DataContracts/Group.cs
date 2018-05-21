namespace OwinFramework.Authorization.Core.DataContracts
{
    /// <summary>
    /// The database representation of a group of identities with the 
    /// same permissions
    /// </summary>
    public class Group
    {
        /// <summary>
        /// Primary key for this group in the database
        /// </summary>
        public long Id { get; set; }

        /// <summary>
        /// An internal name for this group that is referred to in the 
        /// source code of the application and should not be changed in
        /// the database
        /// </summary>
        public string CodeName { get; set; }

        /// <summary>
        /// The name of this group displayed in the UI
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// A description of this group to help with administration. The
        /// description should either describe the identities that belong
        /// in this group, or describe the permissions that identities
        /// in this group have.
        /// </summary>
        public string Description { get; set; }
    }
}
