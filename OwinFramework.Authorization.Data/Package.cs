using System.Collections.Generic;
using Ioc.Modules;
using OwinFramework.Authorization.Data.DataLayer;
using OwinFramework.Authorization.Data.Interfaces;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;

namespace OwinFramework.Authorization.Data
{
    [Package]
    internal class Package : IPackage
    {
        public string Name { get { return "OWIN Framework authorization middleware data layer"; } }

        public IList<IocRegistration> IocRegistrations
        {
            get
            {
                return new List<IocRegistration>
                {
                    new IocRegistration().Init<IAuthorizationData, AuthorizationData>(),

                    new IocRegistration().Init<IContextFactory>(),
                    new IocRegistration().Init<ICommandFactory>(),
                    new IocRegistration().Init<IConfigurationStore>()
                };
            }
        }

    }
}
