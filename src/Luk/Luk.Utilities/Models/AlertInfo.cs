using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class AlertInfo
    {
        public int AlertId { get; set; }

        public DateTime CreationTimeStamp { get; set; }

        public string LicensePlateNo { get; set; }

        public string AlertText { get; set; }

        public string LicensePlateState { get; set; }

        public bool IsActive { get; set; } = true;

        public string SourceJson { get; set; } = string.Empty;
    }
}
