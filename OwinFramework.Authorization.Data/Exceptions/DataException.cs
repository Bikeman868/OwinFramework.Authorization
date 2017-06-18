using System;

namespace OwinFramework.Authorization.Data.Exceptions
{
    public class DataException: Exception
    {
        public DataException(string message, Exception innerException = null)
            : base(message, innerException)
        {
        }
    }
}
