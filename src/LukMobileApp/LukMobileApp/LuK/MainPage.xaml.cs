using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace LuK
{
    public partial class MainPage : ContentPage
    {
        INotificationManager notificationManager;
        int notificationNumber = 0;
        ICameraManager cameraManager;
        IMLModel mLModel;
        public MainPage()
        {
            InitializeComponent();

            BindingContext = this;
            //LicensePlate.Text = "WB 38 Q 9613";
            var database = App.LocalDatabase;
            List<AmberAlert> amberAlerts = database.GetAmberAlertAsync().Result;

            notificationManager = DependencyService.Get<INotificationManager>();
            cameraManager = DependencyService.Get<ICameraManager>();
            mLModel = new MlModelClass();
            notificationManager.NotificationReceived += (sender, eventArgs) =>
            {
                var evtData = (NotificationEventArgs)eventArgs;
                ActOnNotification(evtData.Title, evtData.Message, evtData.Name, amberAlerts);
            };
           
        }
        void OnSendClick(object sender, EventArgs e)
        {
            notificationNumber++;
            string title = $"Amber alert Raised for License Plate number ";
            string message = "WB 38 Q 9613";
            string name = "AmberAlertNotification";
            notificationManager.SendNotification(title, message, name);
            
        }
        void ActOnNotification(string title, string message, string name, List<AmberAlert> amberAlerts)
        {
            AppDescription.IsVisible = false;
            if(name.Equals("AmberAlertNotification", StringComparison.OrdinalIgnoreCase))
            {
                ActOnPushNotificationForAmberAlert(title, message, name, amberAlerts);

            }
            else if(name.Equals("MatchForLicensePlateNotification", StringComparison.OrdinalIgnoreCase))
            {
                ActOnPushNotificationForMatchFound(title, message, name);
            }
           
        }

        async Task ActOnPushNotificationForAmberAlert(string title, string message, string name, List<AmberAlert> amberAlerts)
        {
            Device.BeginInvokeOnMainThread(() =>
            {
                // var text = $"Notification Received:\nTitle: {title}\nMessage: {message}"

                Message.Text = title;
                LicensePlate.Text = message;
                Message.IsVisible = true;
                WelcomeText.IsVisible = false;
                TakeAction.IsVisible = false;
            });
            //  string notificationTitle = $"Scan For License Plate Number :{message} ";
            //   string notificationMessage = message;
            // string notificationName = "ScanForLicensePlateNotification";
            // notificationManager.SendNotification(notificationTitle, notificationMessage, notificationName);
            //await DisplayAlert(notificationTitle, notificationMessage, "dismiss");
            ScanLicensePlates(amberAlerts);
        }

        async Task ScanLicensePlates(List<AmberAlert> amberAlerts)
        {
            // get the licence plate number as well if match is found, currently displaying default number. 
                var isMatchFound = await FindMatch(amberAlerts);
                if (isMatchFound)
                {
                    Device.BeginInvokeOnMainThread(() =>
                    {
                        // var text = $"Notification Received:\nTitle: {title}\nMessage: {message}"
                        Message.Text = "Match Found!!";
                        LicensePlate.Text = amberAlerts.First().LicensePlateNo;
                        LicensePlate.IsVisible = true;
                        Message.IsVisible = true;
                        WelcomeText.IsVisible = false;
                        TakeAction.IsVisible = true;

                    });
                    // Send telemetry to Dashboard
                    notificationManager.SendNotification("Match Found License Plate Number!!", amberAlerts.First().LicensePlateNo, "MatchForLicensePlateNotification");
                }
        }
        async Task ActOnPushNotificationForMatchFound(string title, string message, string name)
        {
           
           
                Device.BeginInvokeOnMainThread(() =>
                {
                    // var text = $"Notification Received:\nTitle: {title}\nMessage: {message}"
                    Message.Text = "Match Found!!";
                    LicensePlate.Text = message;
                    LicensePlate.IsVisible = true;
                    Message.IsVisible = true;
                    WelcomeText.IsVisible = false;
                    TakeAction.IsVisible = true;

                });
                

        }

        void OpenCamera()
        {
            cameraManager.OpenCamera();
        }

        async Task<bool> FindMatch(List<AmberAlert> amberAlerts)
        {
            return await mLModel.FindMatch(amberAlerts);
        }
        
       
    }
}
