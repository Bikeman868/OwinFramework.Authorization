using System.Collections.Generic;
using Ioc.Modules;
using OwinFramework.Authorization.Core.Interfaces;

namespace OwinFramework.Authorization.UI
{
    [Package]
    internal class Package : IPackage
    {
        public string Name { get { return "OWIN Framework authorization UI middleware"; } }

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
