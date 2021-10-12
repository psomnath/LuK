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
            var hourKeysuffix = DateTime.Now.Hour < 10 ? "0" : "";

            var idValue1 = @$"{DateTime.Now.Month}{daysuffix}{DateTime.Now.Day}{hourKeysuffix}{DateTime.Now.Hour}{0}";

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
                LicensePlateNo = "VW57911",
                LicensePlateState = "NC"
            });
            alerts.Add(new AlertInfo()
            {
                AlertId = int.Parse(idValue1) + 3,
                AlertText = "This is a test alert ",
                CreationTimeStamp = DateTime.Now,
                LicensePlateNo = "28809T1",
                LicensePlateState = "TX"
            });

            return alerts;
        }
    }
}
