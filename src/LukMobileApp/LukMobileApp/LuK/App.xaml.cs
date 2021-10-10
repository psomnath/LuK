using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace LuK
{
    public partial class App : Application
    {
        private static LocalDatabase _localDatabase;

        public static LocalDatabase LocalDatabase
        {
            get
            {
                if (_localDatabase == null)
                {
                    _localDatabase = new LocalDatabase(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "amberAlert.db0"));
                }
                return _localDatabase;
            }
        }


        public App()
        {
            InitializeComponent();

            //MainPage = new MainPage();
            MainPage = new NavigationPage(new MainPage());
        }

        protected override void OnStart()
        {
            // Populate the DB when app is started
            List<AmberAlert> amberAlerts = GetAmberAlertsAsync().Result;
            LocalDatabase.SaveAmberAlertAsync(amberAlerts);
        }

        protected override void OnSleep()
        {
        }

        protected override void OnResume()
        {
        }
        private async Task<List<AmberAlert>> GetAmberAlertsAsync()
        {
            HttpClient httpClient = new HttpClient();
            string response = "";
            try
            {
                response = httpClient.GetStringAsync("https://lukapi.azurewebsites.net/amberalert").Result;
            }
            catch(Exception e)
            {

            }
            List<AmberAlert> amberAlerts = JsonConvert.DeserializeObject<List<AmberAlert>>(response);

            return amberAlerts;
        }

    }
}
