namespace OwinFramework.Authorization.Core.DataContracts
{
    /// <summary>
    /// The database representation of a permission that is tested 
    /// by the application software before allowing access to
    /// restricted features.
    /// </summary>
    public class Permission
    {
        /// <summary>
        /// Database primary key value
        /// </summary>
        public long Id { get; set; }

        /// <summary>
        /// An internal name for this permission that is referred to in the 
        /// source code of the application and should not be changed in
        /// the database
        /// </summary>
        public string CodeName { get; set; }

        /// <summary>
        /// The name of this permission displayed in the UI
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// Optional restriction on the permission limiting it to only a
        /// subset of the protected resources. For example there might be a
        /// permission for cancelling an order, some users might be able to
        /// cancel any order whereas other users can only cancel orders that
        /// they placed on the system.
        /// </summary>
        public string Resource { get; set; }

        /// <summary>
        /// A description of what this permission gives access to. This is
        /// displayed in the UI to helf the person managing the system to
        /// decide whether to assign this permission to users
        /// </summary>
        public string Description { get; set; }
    }
}
