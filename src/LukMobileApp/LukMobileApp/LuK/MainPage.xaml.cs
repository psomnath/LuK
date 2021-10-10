using Plugin.Media;
using Plugin.Permissions;
using Plugin.Permissions.Abstractions;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace LuK
{
    public partial class MainPage : ContentPage
    {
        INotificationManager notificationManager;
        int notificationNumber = 0;
        IMLModel mLModel;
        public MainPage()
        {
            InitializeComponent();

            BindingContext = this;
            //LicensePlate.Text = "WB 38 Q 9613";
            CrossMedia.Current.Initialize();

            notificationManager = DependencyService.Get<INotificationManager>();
            mLModel = new MlModelClass();
            notificationManager.NotificationReceived += (sender, eventArgs) =>
            {
                var evtData = (NotificationEventArgs)eventArgs;
                ActOnNotification(evtData.Title, evtData.Message, evtData.Name);
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
        void ActOnNotification(string title, string message, string name)
        {
            AppDescription.IsVisible = false;
            if(name.Equals("AmberAlertNotification", StringComparison.OrdinalIgnoreCase))
            {
                ActOnPushNotificationForAmberAlert(title, message, name);

            }
            else if(name.Equals("MatchForLicensePlateNotification", StringComparison.OrdinalIgnoreCase))
            {
                ActOnPushNotificationForMatchFound(title, message, name);
            }
           
        }

        async Task ActOnPushNotificationForAmberAlert(string title, string message, string name = null)
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
            ScanLicensePlates(message);
        }

        async Task ScanLicensePlates(string message)
        {
            await OpenCamera();
           
            var isMatchFound = await FindMatch(message);
            if (isMatchFound)
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
                notificationManager.SendNotification("Match Found License Plate Number!!", message, "MatchForLicensePlateNotification");
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
        async Task OpenCamera()
        {
            

            //await CrossMedia.Current.Initialize();
            if (!CrossMedia.Current.IsCameraAvailable || !CrossMedia.Current.IsTakeVideoSupported)
            {
                await DisplayAlert("No Camera", ":( No camera avaialble.", "OK");
                return;
            }
            try 
            {
                
                await CrossMedia.Current.TakeVideoAsync(new Plugin.Media.Abstractions.StoreVideoOptions
                {
                    SaveToAlbum = false,
                    Directory = "VideoFolder",
                     
                });
                /*Device.BeginInvokeOnMainThread(() => 
                await CrossMedia.Current.TakeVideoAsync(new Plugin.Media.Abstractions.StoreVideoOptions
                {
                    SaveToAlbum = false
                }));*/
       
            }
            catch(Exception e)
            {

                await DisplayAlert("Camera Error", e.Message, "Dismiss");
            }

        }

        async Task<bool> FindMatch(string licensePlateNumber)
        {
            return await mLModel.FindMatch(licensePlateNumber);
        }


    }
}
