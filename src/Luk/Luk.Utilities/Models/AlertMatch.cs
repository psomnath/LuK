using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class AlertMatch
    {
        public int AlertId { get; set; }

        public DateTime CapturedTimeStamp { get; set; }

        public string LicensePlateNo { get; set; }

        public string DeviceId { get; set; }

        public string GeoLocation { get; set; }
    }
}
