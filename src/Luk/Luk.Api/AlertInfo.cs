using System;

namespace Luk.Api
{
    public class AlertInfo
    {
        public Guid AlertId { get; set; }

        public DateTime CreationTimeStamp { get; set; }
        
        public string LicensePlateNo { get; set; }

        public string AlertText { get; set; }
    }
}
