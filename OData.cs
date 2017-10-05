using System;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.OData.Client;
using ODataUtility.Microsoft.Dynamics.DataEntities;
using System.Linq;

namespace MockVehicle
{
    class ODatatest
    {
        // Class variables
        private static string _authorizationHeader;
        private static AuthenticationResult _authResult { get; set; }

        /// <summary>
        /// The header to use for OAuth.
        /// </summary>
        public const string OAuthHeader = "Authorization";

        private static string aadTenant = "72f988bf-86f1-41af-91ab-2d7cd011db47";
        private static string aadClientAppId = "ef45fda5-2448-4a19-8c95-2c3d8da3cb62";
       // private static string aadResource = "https://msddma365testdc751c23ff8636b7aos.cloudax.dynamics.com";
          private static string aadResource = "https://msddma365leob9aa7a462e1e55c0aos.cloudax.dynamics.com";
        // Added following two
        private static string azureEndPoint = "https://login.windows.net";
        private static string aadClientSecret = "lkoe79IF4fm7+zM7UjGSFxVqIvPDYfgzpw7lWACC4xA=";
       // public static string AxODataServiceElement = "https://msddma365testdc751c23ff8636b7aos.cloudax.dynamics.com/data";
         private static string AxODataServiceElement = "https://msddma365leob9aa7a462e1e55c0aos.cloudax.dynamics.com/data/cross-company=true";

        public static async Task<string> AuthorizationHeader()
        {
            try
            {
                if (!string.IsNullOrEmpty(_authorizationHeader) && DateTime.UtcNow.AddSeconds(180) < _authResult.ExpiresOn)
                    return _authorizationHeader;

                var uri = new UriBuilder(azureEndPoint) { Path = aadTenant };
                var authContext = new AuthenticationContext(uri.ToString());

                // Get token object
                var userCredential = new UserPasswordCredential("v-jyyala@microsoft.com", "Password");
             
                _authResult = await authContext.AcquireTokenAsync(aadResource, aadClientAppId, userCredential);

                _authorizationHeader = _authResult.CreateAuthorizationHeader();
                return _authorizationHeader;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                throw ex;
            }
        }
        
        public void Execute()
        {
            var service = Activator.CreateInstance(typeof(Resources), new Uri(AxODataServiceElement));
            var dataServiceContext = service as DataServiceContext;
            if (dataServiceContext != null)
            {
                Uri oDataUri = new Uri(AxODataServiceElement, UriKind.Absolute);
                string header = string.Empty;
                dataServiceContext.SendingRequest2 += new EventHandler<SendingRequest2EventArgs>(delegate (object sender, SendingRequest2EventArgs e)
                {
                    var response = Task.Run(async () =>
                    {
                        return await AuthorizationHeader();
                    }
                    );
                    response.Wait();
                    e.RequestMessage.SetHeader(OAuthHeader, response.Result.ToString());
                });
            }
            var vehicle = new VehicleTable
            {
                VIN = "Test213",
                dataAreaId = "USMF",
                Name = "Test213"
            };

            //VehicleTable vehicle = new VehicleTable();
            //var expectedDelivery = new ExpectedDelivery
            //{
            //    dataAreaId = "usmf",
            //    DMSDocumentState = DMSDocumentState.Draft,
            //    DMSTransType = DMSTransType.SalesOrder,
            //    ExpectedDeliveryNumber = "000001"
            //};

            dataServiceContext.AddObject(GetEntityKey(vehicle.GetType()), vehicle);
           dataServiceContext.SaveChanges();
        }
        private void releasedProduct(Resources dsc)
        {

            var releasedProd = dsc.DMSEcoResReleasedProductMasters.Where(x => x.ItemNumber == "DDMATestMaster").First();
            DataServiceCollection<DMSEcoResReleasedProductMaster> vehicleCollection = new DataServiceCollection<DMSEcoResReleasedProductMaster>(dsc);
            vehicleCollection.Add(releasedProd);

            releasedProd.PurchStopped = NoYes.Yes;
            releasedProd.SalesStopped = NoYes.Yes;


            //dsc.UpdateObject(releasedProd);
            dsc.SaveChanges();

        }
        public void mockVehicle()
        {
            Uri oDataUri = new Uri(AxODataServiceElement, UriKind.Absolute);
            //private static Uri oDataUri = new Uri(ODataEntityPath, UriKind.Absolute);
            Resources dataServiceContext = new Resources(oDataUri);
            if (dataServiceContext != null)
            {
                //Uri oDataUri = new Uri(ClientConfiguration.AxODataServiceElement, UriKind.Absolute);
                string header = string.Empty;
                dataServiceContext.SendingRequest2 += new EventHandler<SendingRequest2EventArgs>(delegate (object sender, SendingRequest2EventArgs e)
                {
                    var response = Task.Run(async () =>
                    {
                        return await AuthorizationHeader();
                    }
                     );
                    response.Wait();
                    e.RequestMessage.SetHeader("Authorization", response.Result.ToString());
                });
            }

            //foreach (var legalEntity in dataServiceContext.LegalEntities.AsEnumerable())
            //{
            //    Console.WriteLine("Name: {0}", legalEntity.Name);
            //}
            //ODataClient client = new ODataClient(settings);

            //model = client.GetMetadataAsync().ConfigureAwait(false).GetAwaiter().GetResult();
            //List<string> entities = getEntities(model).ToList();

            //// Now preparing the query to get the records from one of the entity .

            //var query = client.For("<Entity Name>");


            try
            { 
          //  var data = Task.Run(() => query.FindEntriesAsync()).ConfigureAwait(false).GetAwaiter().GetResult();
            VehicleTable vehicle = new VehicleTable();
            // DMSMockVehicleTable vehicle1 = new DMSMockVehicleTable();
            DataServiceCollection<VehicleTable> vehicleCollection = new DataServiceCollection<VehicleTable>(dataServiceContext);
             vehicleCollection.Add(vehicle);

            vehicle.Name = "Test2";
            vehicle.VIN = "Test2";

            vehicle.dataAreaId = "USMF";
            //dataServiceContext.AddObject(GetEntityKey(vehicle.GetType()), vehicle);
             dataServiceContext.SaveChanges(SaveChangesOptions.PostOnlySetProperties | SaveChangesOptions.BatchWithSingleChangeset);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                throw ex;
            }
            //dataServiceContext.SaveChanges();
        }

        public void test()
        {

        }

        protected string GetEntityKey(Type type)
        {
            var attr = type.GetCustomAttributes(typeof(EntitySetAttribute), false).FirstOrDefault() as EntitySetAttribute;
            if (attr == null)
            {
                return null;
            }

            return attr.EntitySet;
        }
    }
}
