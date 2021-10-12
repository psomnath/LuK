using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class ActiveAmberAlerts
    {
        public class Root
        {
            [JsonProperty("status")]
            public string Status { get; set; }

            [JsonProperty("type")]
            public string Type { get; set; }

            [JsonProperty("alertCount")]
            public int AlertCount { get; set; }

            [JsonProperty("persons")]
            public List<Alert> ActiveAlerts { get; set; }
        }
        public class Alert
        {
            [JsonProperty("amberId")]
            public int AmberId { get; set; }

            [JsonProperty("personId")]
            public int PersonId { get; set; }

            [JsonProperty("firstName")]
            public string FirstName { get; set; }

            [JsonProperty("midName")]
            public string MidName { get; set; }

            [JsonProperty("lastName")]
            public string LastName { get; set; }

            [JsonProperty("state")]
            public string State { get; set; }

            [JsonProperty("city")]
            public string City { get; set; }

            [JsonProperty("issuedFor")]
            public string IssuedFor { get; set; }

            [JsonProperty("imageUrl")]
            public string ImageUrl { get; set; }

            [JsonProperty("alertDate")]
            public string AlertDate { get; set; }
        }
    }
}
