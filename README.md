# Dynamics365ForOperation
Dynamics 365 for operation/ Ax7

# Delete a Pacakge in Dynamics365 for Operation / AX7 /D365FO

On a development or test environment, follow these steps to delete a model.
The following steps assume the local model store folder is C:\AOSService\PackagesLocalDirectory and your model is named MyModel1.
If your model belongs to its own package (For example: An extension package with no other models in the package):
Stop the following services: The AOS web service and the Batch Management Service
Delete the package folder C:\AOSService\PackagesLocalDirectory\MyModel1
Restart the services from step 1
If Visual Studio is running, refresh your models (Visual Studio > Dynamics 365 > Model management > Refresh models)
In Visual Studio, perform a full database synchronization (Visual Studio > Dynamics 365 > Synchronize database...)
If your model belongs to a package with multiple models (For example, MyModel1 overlays Application Suite):
Stop the following services: The AOS web service and the Batch Management Service
Delete the model folder C:\AOSService\PackagesLocalDirectory<PackageName>\MyModel1 (In this example PackageName=ApplicationSuite)
Restart the services from step 1
In Visual Studio, refresh your models (Visual Studio > Dynamics 365 > Model management > Refresh models)
In Visual Studio, build the package that the deleted models belonged to (Visual Studio > Dynamics 365 > Build models...)
In Visual Studio, perform a full database synchronization (Visual Studio > Dynamics 365 > Synchronize database...)


# Test OData and rest service for D365FO in Local Box /VHD

1.	Open Dynamics 365FO browser session in chrome and Press F12
 
2.	Click on console button on right side bar and then use below java script code to test the service.
Example for using CustomerGroup rest service

const bodyGrp = '{"dataAreaId":"3000","CustomerGroupId":"0VV","ClearingPeriodPaymentTermName":"","CustomerAccountNumberSequence":"","DefaultDimensionDisplayValue":"","Description":"Vehicle Vishram","IsSalesTaxIncludedInPrice":"No","WriteOffReason":"","PaymentTermId":"","TaxGroupId":""}'

const response = await fetch('https://usnconeboxax1aos.cloud.onebox.dynamics.com/data/CustomerGroups', {
    method: 'POST',
    body: bodyGrp, // string or object
    headers:{
      'Content-Type': 'application/json'
    }
  });
  const myJson = await response.json(); 
   console.log(myJson)
  
3.	Change example code as per your service and press enter .
 

