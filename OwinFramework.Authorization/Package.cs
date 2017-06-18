using System.Collections.Generic;
using Ioc.Modules;
using OwinFramework.Authorization.Data.Interfaces;

namespace OwinFramework.Authorization
{
    [Package]
    internal class Package : IPackage
    {
        public string Name { get { return "OWIN Framework authorization middleware"; } }

        public IList<IocRegistration> IocRegistrations
        {
            get
            {
                return new List<IocRegistration>
                {
                    new IocRegistration().Init<IAuthorizationData>(),
                };
            }
        }

    }
}
