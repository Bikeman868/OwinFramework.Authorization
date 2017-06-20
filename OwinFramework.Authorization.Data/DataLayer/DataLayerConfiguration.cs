namespace OwinFramework.Authorization.Data.DataLayer
{
    public class DataLayerConfiguration
    {
        public string PriusRepositoryName { get; set; }
        public string DefaultUserGroup { get; set; }
        public string AdministratorUserGroup { get; set; }

        public DataLayerConfiguration()
        {
            PriusRepositoryName = "Authorization";
            DefaultUserGroup = "Users";
            AdministratorUserGroup = "Administrators";
        }
    }
}
