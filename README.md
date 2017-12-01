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
