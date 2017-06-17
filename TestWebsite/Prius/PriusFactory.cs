using System;
using Ninject;
using Prius.Contracts.Interfaces.External;

namespace TestWebsite.Prius
{
    internal class PriusFactory : IFactory
    {
        public static StandardKernel Ninject;

        public object Create(Type type)
        {
            return Ninject.Get(type);
        }

        public T Create<T>() where T : class
        {
            return Ninject.Get<T>();
        }
    }
}
