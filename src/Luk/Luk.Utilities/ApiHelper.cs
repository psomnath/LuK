using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Luk.Utilities
{
    public class ApiHelper
    {
        HttpClient httpClient = null;

        public ApiHelper()
        {
            httpClient = new HttpClient(new HttpClientHandler() { UseDefaultCredentials = true });
            httpClient.DefaultRequestHeaders.Accept.Add(
                    new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
        }

        public Task<string> GetAsync(string apiUrl)
        {
            return httpClient.GetStringAsync(apiUrl);
        }
    }
}
