using System;

namespace OwinFramework.Authorization.Prius.Exceptions
{
    public class UpdateFailedException: Exception
    {
        public UpdateFailedException(string recordType, long id, Exception innerException)
            : base(string.Format("Failed to update {0} record with ID={1}", recordType, id), innerException)
        {
        }
    }
}
