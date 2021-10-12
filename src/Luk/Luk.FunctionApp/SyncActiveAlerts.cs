using System;
using System.Collections.Generic;
using Luk.Utilities;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace Luk.FunctionApp
{
    public static class SyncActiveAlerts
    {
        [FunctionName("SyncActiveAlerts")]
        public static void Run([TimerTrigger("0 */5 * * * *", RunOnStartup = true)]TimerInfo myTimer, ILogger log)
        {
            AmberAlertConsumer alertConsumer = new AmberAlertConsumer();

            var data = alertConsumer.GetActiveAlertsWithDetails();

            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
        }
    }
}
