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
            var sampleAlerts = new List<AlertInfo>()
            { 
                new AlertInfo()
                {
                    AlertId = Guid.NewGuid(),
                    AlertText = "sample alert",
                    CreationTimeStamp = DateTime.Now,
                    LicensePlateNo = "zzzzzzzz"
                }
            };
            return sampleAlerts;
        }
    }
}
