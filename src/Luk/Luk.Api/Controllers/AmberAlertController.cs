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
        KustoHelper kustoHelper = null;

        public AmberAlertController(ILogger<AmberAlertController> logger)
        {
            _logger = logger;
            kustoHelper = new KustoHelper();
        }

        [HttpGet]
        public IEnumerable<AlertInfo> Get()
        {
            var newAlerts = kustoHelper.GetActiveAlertsFromKusto();

            return newAlerts;
        }

        [HttpPost]
        [Route("Report")]
        public void ReportFindings([FromBody] AlertMatch matchedAlert)
        {
            if(!string.IsNullOrEmpty(matchedAlert.geoLocation) && matchedAlert.Latitude==0.0)
            {
                var geoLocParts = matchedAlert.geoLocation.Split(',');
                if (double.TryParse(geoLocParts[0], out double lat) && double.TryParse(geoLocParts[1], out double lon))
                {
                    matchedAlert.Latitude = lat;
                    matchedAlert.Longitude = lon;
                }
            }

            kustoHelper.InsertIntoMatchedAlerts(matchedAlert);
        }
    }
}
