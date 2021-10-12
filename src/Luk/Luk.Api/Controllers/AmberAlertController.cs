using Luk.Utilities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Luk.Api.Controllers
{
    [ApiController]
    [Route("amberalert")]
    public class AmberAlertController : ControllerBase
    {
        private readonly ILogger<AmberAlertController> _logger;

        public AmberAlertController(ILogger<AmberAlertController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IEnumerable<AlertInfo> Get()
        {
            AmberAlertConsumer alertConsumer = new AmberAlertConsumer();

            var newAlerts = alertConsumer.GetActiveAlertsWithDetails();

            if(newAlerts.Count==0)
            {
                newAlerts = SampleDataProducer.ProduceSampleAlerts();
            }

            return newAlerts;
        }
        [HttpPost]
        [Route("Report")]
        public int ReportFindings([FromBody] AlertMatch matchedAlert)
        {
            
            return 2;
        }
    }
}
