using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace Luk.Utilities
{
    public class AmberAlertExpanded
    {
        // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse); 
        public class VehicleList
        {
            [JsonProperty("vehicleId")]
            public int VehicleId { get; set; }

            [JsonProperty("personId")]
            public int PersonId { get; set; }

            [JsonProperty("amberId")]
            public int AmberId { get; set; }

            [JsonProperty("make")]
            public string Make { get; set; }

            [JsonProperty("model")]
            public string Model { get; set; }

            [JsonProperty("modelYear")]
            public string ModelYear { get; set; }

            [JsonProperty("style")]
            public string Style { get; set; }

            [JsonProperty("colorPrimary")]
            public string ColorPrimary { get; set; }

            [JsonProperty("colorSecondary")]
            public string ColorSecondary { get; set; }

            [JsonProperty("colorInterior")]
            public string ColorInterior { get; set; }

            [JsonProperty("licensePlateText")]
            public string LicensePlateText { get; set; }

            [JsonProperty("licensePlateState")]
            public string LicensePlateState { get; set; }

            [JsonProperty("vehicleDescription")]
            public string VehicleDescription { get; set; }

            [JsonProperty("newVehicle")]
            public int NewVehicle { get; set; }
        }

        public class PersonList
        {
            [JsonProperty("amberId")]
            public int AmberId { get; set; }

            [JsonProperty("personId")]
            public int PersonId { get; set; }

            [JsonProperty("personType")]
            public string PersonType { get; set; }

            [JsonProperty("firstName")]
            public string FirstName { get; set; }

            [JsonProperty("middleName")]
            public string MiddleName { get; set; }

            [JsonProperty("lastName")]
            public string LastName { get; set; }

            [JsonProperty("suffix")]
            public string Suffix { get; set; }

            [JsonProperty("monikerName")]
            public string MonikerName { get; set; }

            [JsonProperty("gender")]
            public string Gender { get; set; }

            [JsonProperty("eyeColor")]
            public string EyeColor { get; set; }

            [JsonProperty("hairColor")]
            public string HairColor { get; set; }

            [JsonProperty("skinColor")]
            public string SkinColor { get; set; }

            [JsonProperty("height")]
            public string Height { get; set; }

            [JsonProperty("weight")]
            public string Weight { get; set; }

            [JsonProperty("pictureFormat")]
            public string PictureFormat { get; set; }

            [JsonProperty("imageUrl")]
            public string ImageUrl { get; set; }

            [JsonProperty("externalPictureImageHeight")]
            public int ExternalPictureImageHeight { get; set; }

            [JsonProperty("externalPictureImageWidth")]
            public int ExternalPictureImageWidth { get; set; }

            [JsonProperty("pictureDescription")]
            public string PictureDescription { get; set; }

            [JsonProperty("description")]
            public string Description { get; set; }

            [JsonProperty("age")]
            public string Age { get; set; }

            [JsonProperty("newPerson")]
            public int NewPerson { get; set; }

            [JsonProperty("hasPicture")]
            public bool HasPicture { get; set; }

            [JsonProperty("fullName")]
            public string FullName { get; set; }

            [JsonProperty("vehicleList")]
            public List<VehicleList> VehicleList { get; set; }
        }

        public class ChildBean
        {
            [JsonProperty("amberId")]
            public int AmberId { get; set; }

            [JsonProperty("isPreview")]
            public bool IsPreview { get; set; }

            [JsonProperty("lastSeenState")]
            public string LastSeenState { get; set; }

            [JsonProperty("lastSeenCity")]
            public string LastSeenCity { get; set; }

            [JsonProperty("timeZone")]
            public string TimeZone { get; set; }

            [JsonProperty("lastSeenDate")]
            public string LastSeenDate { get; set; }

            [JsonProperty("lastSeenDay")]
            public string LastSeenDay { get; set; }

            [JsonProperty("orgName")]
            public string OrgName { get; set; }

            [JsonProperty("circumstances")]
            public string Circumstances { get; set; }

            [JsonProperty("contactOrg")]
            public string ContactOrg { get; set; }

            [JsonProperty("contactPhone")]
            public string ContactPhone { get; set; }

            [JsonProperty("personList")]
            public List<PersonList> PersonList { get; set; }

            [JsonProperty("vehicleList")]
            public List<object> VehicleList { get; set; }

            [JsonProperty("targetList")]
            public List<string> TargetList { get; set; }

            [JsonProperty("messageList")]
            public List<object> MessageList { get; set; }

            [JsonProperty("missingFrom")]
            public string MissingFrom { get; set; }

            [JsonProperty("missingDate")]
            public string MissingDate { get; set; }
        }

        public class Root
        {
            [JsonProperty("status")]
            public string Status { get; set; }

            [JsonProperty("childBean")]
            public ChildBean ChildBean { get; set; }
        }
    }
}
