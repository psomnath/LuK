using Kusto.Data;
using Kusto.Data.Common;
using Kusto.Data.Net.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Luk.Utilities
{
    public class KustoHelper
    {
        private const string _TenantId = "59086a18-c7f3-471b-9feb-77bd34f9fc0f";
        private const string _ClientId ="5944a40b-8b58-41c9-83b8-bab7ca16c77a";
        private const string _AppKey= "NUr7Q~B3sDzqZ~_HTXH4NYIRgvtvRPjpjxKgM";
        private const string _KustoCluster = "https://azlearn.westus.kusto.windows.net";
        private const string _KustoDatabase = "LukMaster";



        private KustoConnectionStringBuilder kustoConnectionString = null;
        public KustoHelper()
        {
            try
            {
                kustoConnectionString = new KustoConnectionStringBuilder(_KustoCluster, _KustoDatabase).WithAadApplicationKeyAuthentication(
                                    _ClientId,
                                    _AppKey,
                                    _TenantId);

            }
            catch (Exception ex)
            {
                throw new Exception("Error creating KustoHelper", ex);
            }
        }

        public void ClearActiveAlertsQueue()
        {
            ExecuteKustoManagementCommand(KustoQueries.CLEAR_ACTIVEALERTS);
        }

        public void InsertIntoActiveAlerts(List<AlertInfo> data)
        {
            foreach (AlertInfo alert in data)
            {
                string query = string.Format(KustoQueries.INSERT_INTO_ACTIVEALERTS, Environment.NewLine, alert.AlertId,
                           alert.CreationTimeStamp.ToString("o").Substring(0, 19), alert.LicensePlateNo, alert.AlertText, alert.LicensePlateState, alert.SourceJson, Guid.NewGuid());

                ExecuteKustoManagementCommand(query);
            }
        }

        public void UpdateAlertsMaster()
        {
            ExecuteKustoManagementCommand(KustoQueries.UPDATE_ALERTS_MASTER);
        }

        public void InsertIntoMatchedAlerts(AlertMatch data)
        {
            string query = string.Format(KustoQueries.INSERT_INTO_MATCHEDALERTS, Environment.NewLine, data.AlertId,
                            data.CapturedTimeStamp.ToString("o").Substring(0, 19), data.LicensePlateNo, data.Latitude, data.Longitude, data.DeviceId, Guid.NewGuid(), data.CapturedImageUrl);

            ExecuteKustoManagementCommand(query);
        }

        private void ExecuteKustoManagementCommand(string query)
        {
            try
            {
                using (var kustoClient = KustoClientFactory.CreateCslAdminProvider(kustoConnectionString))
                {
                    var command = kustoClient.ExecuteControlCommand(query);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error writing into Kusto Table", ex);
            }
        }

        public List<AlertInfo> GetActiveAlertsFromKusto()
        {
            ICslQueryProvider queryProvider = KustoClientFactory.CreateCslQueryProvider(kustoConnectionString);
            var clientRequestProperties = new ClientRequestProperties() { ClientRequestId = Guid.NewGuid().ToString() };
            var reader = queryProvider.ExecuteQuery(KustoQueries.GET_ACTIVEALERTS, clientRequestProperties);
            try
            {
                List<AlertInfo> alerts = new List<AlertInfo>();
                while (reader.Read())
                {
                    AlertInfo alert = new AlertInfo()
                    {
                        AlertId = int.Parse(reader["AlertId"].ToString()),
                        CreationTimeStamp = DateTime.Parse(reader["CreationTimeStamp"].ToString()),
                        LicensePlateNo = reader["LicensePlateNo"].ToString(),
                        AlertText = reader["AlertText"].ToString(),
                        LicensePlateState = reader["LicensePlateState"].ToString()
                    };
                    alerts.Add(alert);
                }
                return alerts;
            }
            catch (Exception ex)
            {
                throw new Exception("Error reading Kusto Table", ex);
            }
            finally
            {
                reader.Dispose();
            }
            return null;
        }
    }

    public static class KustoQueries
    {
        public static string CLEAR_ACTIVEALERTS = ".clear table ActiveAlerts data";

        public static string INSERT_INTO_ACTIVEALERTS = ".ingest inline into table ActiveAlerts <| {0} {1}, \"{2}\", \"{3}\", \"{4}\", \"{5}\" ,\"{6}\",\"{7}\"";
        public static string INSERT_INTO_MATCHEDALERTS = ".ingest inline into table MatchedAlerts <| {0} {1}, \"{2}\", \"{3}\", {4}, {5} ,\"{6}\",\"{7}\",{8}";

        public static string GET_ACTIVEALERTS = "ActiveAlerts | project AlertId, CreationTimeStamp, LicensePlateNo, AlertText, LicensePlateState ";

        public static string UPDATE_ALERTS_MASTER = ".set-or-append AlertsMaster<| GetUpdatesToAlertsMaster()";
    }
}
