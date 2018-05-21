namespace OwinFramework.Authorization.Prius.DataLayer
{
    public class DataLayerConfiguration
    {
        public string PriusMasterRepository { get; set; }
        public string PriusReadonlyReplicaRepository { get; set; }
        public string DefaultGroup { get; set; }
        public string AdministratorGroup { get; set; }
        public string AnonymousGroup { get; set; }

        public DataLayerConfiguration()
        {
            PriusMasterRepository = "Authorization";
            PriusReadonlyReplicaRepository = "Authorization";
            DefaultGroup = "sys.users";
            AdministratorGroup = "sys.admins";
            AnonymousGroup = "";
        }
    }
}
