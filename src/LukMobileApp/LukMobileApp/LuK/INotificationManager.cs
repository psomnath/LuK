using System;
using System.Collections.Generic;
using System.Text;

namespace LuK
{
    public interface INotificationManager
    {
        event EventHandler NotificationReceived;
        void Initialize();
        void SendNotification(string title, string message);
        void ReceiveNotification(string title, string message);
    }
}
