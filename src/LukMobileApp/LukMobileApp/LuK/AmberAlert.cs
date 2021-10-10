using System;
using System.Collections.Generic;
using System.Text;
using SQLite;

namespace LuK
{
    public class AmberAlert
    {
        [PrimaryKey]
        [AutoIncrement]
        public Guid AlertId { get; set; }
        public DateTime CreationTimeStamp { get; set; }
        public string LicensePlateNo { get; set; }
        public string AlertText { get; set; }
    }
}
