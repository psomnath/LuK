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
        public MainPage()
        {
            InitializeComponent();

            BindingContext = this;
            LicensePlate.Text = "WB 38 Q 9613";

            notificationManager = DependencyService.Get<INotificationManager>();
            notificationManager.NotificationReceived += (sender, eventArgs) =>
            {
                var evtData = (NotificationEventArgs)eventArgs;
                ShowNotification(evtData.Title, evtData.Message);
            };
            void OnSendClick(object sender, EventArgs e)
            {
                notificationNumber++;
                string title = $"Local Notification #{notificationNumber}";
                string message = $"You have now received {notificationNumber} notifications!";
                notificationManager.SendNotification(title, message);
            }
        }
        void ShowNotification(string title, string message)
        {
            Device.BeginInvokeOnMainThread(() =>
            {
                var msg = new Label()
                {
                    Text = $"Notification Received:\nTitle: {title}\nMessage: {message}"
                };
                LicensePlate.Text = message;
            });
        }
    }
}
