using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class AmberAlertConsumer
    {
        protected const string _AmberAlertRootApi = "https://www.missingkids.org/bin/ncmecEndpoint?endpoint=en_US&rest=&action=amberAlert&Time={0}";
        protected const string _AmberAlertDetailsApi = "https://www.missingkids.org/bin/ncmecEndpoint?endpoint=en_US&rest=&?action=amberDetail&amberId={0}&LanguageId=en_US&Time={1}";


        public List<ActiveAmberAlerts.Alert> GetActiveAlerts()
        {
            var apiHelper = new ApiHelper();

            var apiUrl = string.Format(_AmberAlertRootApi, DateTime.Now.ToString());

            var rootApiresponse = apiHelper.GetAsync(apiUrl).GetAwaiter().GetResult();

            var alertList = JsonConvert.DeserializeObject<ActiveAmberAlerts.Root>(rootApiresponse);
         
            return alertList.ActiveAlerts;
        }

        public List<AlertInfo> GetActiveAlertsWithDetails()
        {
            var alertList = GetActiveAlerts();

            List<AlertInfo> alertDetails = new List<AlertInfo>();
            foreach (var alert in alertList)
            {
                var details = GetAlertDetails(alert.AmberId, alert.AlertDate);
                if (details != null)
                {
                    alertDetails.Add(details);
                }
            }

            return alertDetails;
        }

        public AlertInfo GetAlertDetails(int amberId, string alertDate)
        {
            var apiHelper = new ApiHelper();

            var apiUrl = string.Format(_AmberAlertDetailsApi, amberId, DateTime.Now.ToString());

            var response = apiHelper.GetAsync(apiUrl).GetAwaiter().GetResult();

            var alertInfo = JsonConvert.DeserializeObject<AmberAlertExpanded.Root>(response);

            if (alertInfo != null && alertInfo.ChildBean != null && alertInfo.ChildBean.AmberId!=0)
            {
                var licensePlateNo = GetValidVehiclePlateNo(alertInfo.ChildBean.PersonList, "PlateNo");

                if (!string.IsNullOrEmpty(licensePlateNo))
                {
                    AlertInfo alertDetails = new AlertInfo()
                    {
                        AlertId = alertInfo.ChildBean.AmberId,
                        CreationTimeStamp = DateTime.Parse(alertDate),
                        LicensePlateNo = GetValidVehiclePlateNo(alertInfo.ChildBean.PersonList, "PlateNo"),
                        LicensePlateState = GetValidVehiclePlateNo(alertInfo.ChildBean.PersonList, "State"),
                        AlertText = GetValidDescription(alertInfo.ChildBean.PersonList),
                        IsActive = true,
                        SourceJson = response
                    };
                    return alertDetails;
                }
            }
            return null;
        }
        private string GetValidVehiclePlateNo(List<AmberAlertExpanded.PersonList> personList, string returnType)
        {
            foreach(var person in personList)
            {
                if(person.VehicleList!=null && person.VehicleList.Count>0)
                {
                    if (returnType == "PlateNo")
                    {
                        return person.VehicleList[0].LicensePlateText;
                    }
                    else if(returnType == "State")
                    {
                        return person.VehicleList[0].LicensePlateState;
                    }
                }
            }
            return string.Empty;
        }
        private string GetValidDescription(List<AmberAlertExpanded.PersonList> personList)
        {
            foreach (var person in personList)
            {
                if(person.Description!=null)
                {
                    return person.Description;
                }
            }
            return string.Empty;
        }
    }
}
