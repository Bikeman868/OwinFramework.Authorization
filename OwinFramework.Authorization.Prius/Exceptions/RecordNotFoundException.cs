using System;

namespace OwinFramework.Authorization.Prius.Exceptions
{
    public class RecordNotFoundException: Exception
    {
        public RecordNotFoundException(string recordType, long id, Exception innerException = null)
            : base(string.Format("No {0} record found with ID={1}", recordType, id), innerException)
        {
        }
    }
}
