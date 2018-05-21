using System.Collections.Generic;
using Ioc.Modules;
using OwinFramework.Authorization.Core.Interfaces;
using OwinFramework.Authorization.Prius.DataLayer;
using Prius.Contracts.Interfaces;
using Urchin.Client.Interfaces;

namespace OwinFramework.Authorization.Prius
{
    [Package]
    internal class Package : IPackage
    {
        public string Name { get { return "OWIN Framework authorization data from Prius"; } }

        private AuthorizationData _authorizationData;
        private readonly object _lock = new object();

        private AuthorizationData GetAuthorizationData(IContainer container)
        {
            if (_authorizationData == null)
            {
                lock(_lock)
                {
                    if (_authorizationData == null)
                        _authorizationData = container.Resolve<AuthorizationData>();
                }
            }
            return _authorizationData;
        }

        public IList<IocRegistration> IocRegistrations
        {
            get
            {
                return new List<IocRegistration>
                {
                    new IocRegistration().Init<IIdentityData>(GetAuthorizationData),
                    new IocRegistration().Init<IAuthorizationData>(GetAuthorizationData),

                    new IocRegistration().Init<IContextFactory>(),
                    new IocRegistration().Init<ICommandFactory>(),
                    new IocRegistration().Init<IConfigurationStore>()
                };
            }
        }

    }
}
