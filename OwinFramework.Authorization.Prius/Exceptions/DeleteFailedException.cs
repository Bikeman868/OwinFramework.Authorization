using System;

namespace OwinFramework.Authorization.Prius.Exceptions
{
    public class DeleteFailedException: Exception
    {
        public DeleteFailedException(string recordType, long id, Exception innerException)
            : base(string.Format("Failed to delete {0} record with ID={1}", recordType, id), innerException)
        {
        }
    }
}
