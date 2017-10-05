# Dynamics365ForOperation
Dynamics 365 for operation/ Ax7 OData Test with C#

1.	Create a visual studio Project and go to project add following NuGet package to the project
  Microsoft.OData.Client 6.17.0
  Microsoft.OData.Core
  Microsoft.OData.Edm
  Microsoft.Spatial
  Microsoft.IdentityModel 6.1.7600.16394
  Microsoft.IdentityModel.Clients.ActiveDirectory 3.13.9

2.	Go to Tools -> Extension and updates and install Odata v4 Client code generator
3.	Copy OdataClient.tt and OdataClient.ttinclude from VSTS  Path “src/QuicksStarts/ProductColor/ForOperations”
4.	Add above two files in your projects and open ODataClient.tt and change the path to your metadata as shown below.

 

Then Just save your file in will generate classes and data type for all entities. 
 
5.	In Odata.cs you have your azure active directory settings to authenticate to D365. If you want to connect to different Machine , you can change configuration according to that.
6.	There is one execute method in OData.cs  which have sample code to test ExpectedDelivery , you need to call this method in your Program.cs and start testing.
7.	If you want to write any different method or code , just change in Odata.cs

