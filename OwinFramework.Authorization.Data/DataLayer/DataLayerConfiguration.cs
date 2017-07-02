namespace OwinFramework.Authorization.Data.DataLayer
{
    public class DataLayerConfiguration
    {
        public string PriusRepositoryName { get; set; }
        public string DefaultGroup { get; set; }
        public string AdministratorGroup { get; set; }
        public string AnonymousGroup { get; set; }

        public DataLayerConfiguration()
        {
            PriusRepositoryName = "Authorization";
            DefaultGroup = "sys.users";
            AdministratorGroup = "sys.admins";
            AnonymousGroup = "";
        }
    }
}
