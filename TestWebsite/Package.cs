using System.Collections.Generic;
using Ioc.Modules;
using Prius.Contracts.Interfaces.External;
using TestWebsite.Prius;

namespace TestWebsite
{
    [Package]
    internal class Package : IPackage
    {
        public string Name { get { return "OWIN Framework authorization middleware test site"; } }

        public IList<IocRegistration> IocRegistrations
        {
            get
            {
                return new List<IocRegistration>
                {
                    new IocRegistration().Init<IFactory, PriusFactory>(),
                    new IocRegistration().Init<IErrorReporter, PriusErrorReporter>(),
                };
            }
        }

    }
}
