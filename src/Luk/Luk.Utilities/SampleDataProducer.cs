using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class SampleDataProducer
    {
        public static List<AlertInfo> ProduceSampleAlerts()
        {
            List<AlertInfo> alerts = new List<AlertInfo>();

            var daysuffix = DateTime.Now.Day < 10 ? "0" : "";

            var idValue1 = @$"{DateTime.Now.Year}{DateTime.Now.Month}{daysuffix}{DateTime.Now.Day}{0}";

            alerts.Add(new AlertInfo()
            {
                AlertId = int.Parse(idValue1) + 1,
                AlertText = "This is a test alert ",
                CreationTimeStamp = DateTime.Now,
                LicensePlateNo = "ROXIEE",
                LicensePlateState = "ID"
            });
            alerts.Add(new AlertInfo()
            {
                AlertId = int.Parse(idValue1) + 2,
                AlertText = "This is a test alert ",
                CreationTimeStamp = DateTime.Now,
                LicensePlateNo = "AXR5787",
                LicensePlateState = "WA"
            });
            alerts.Add(new AlertInfo()
            {
                AlertId = int.Parse(idValue1) + 3,
                AlertText = "This is a test alert ",
                CreationTimeStamp = DateTime.Now,
                LicensePlateNo = "BMG6428",
                LicensePlateState = "WA"
            });

            return alerts;
        }
    }
}
