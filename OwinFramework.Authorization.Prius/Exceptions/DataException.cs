using System;

namespace OwinFramework.Authorization.Prius.Exceptions
{
    public class DataException: Exception
    {
        public DataException(string message, Exception innerException = null)
            : base(message, innerException)
        {
        }
    }
}
