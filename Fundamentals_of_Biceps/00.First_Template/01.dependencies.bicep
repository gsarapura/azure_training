/*
You'll need to deploy an App Service app for the template that will help launch the toy product, 
but to create an App Service app, you first need to create an App Service plan.
The App Service plan represents the server-hosting resources, and it's declared like this example:
*/

param location string = resourceGroup().id

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'toy-product-launch-plan'
  location: location
  sku: {
    name: 'F1' // App Services's free tier
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'toy-product-launch-1'
  location: location
  properties: {
    serverFarmId:   appServicePlan.id
    httpsOnly: true
  }
}

/*
This template instructs Azure to host the app on the plan you created. Notice that the plan's definition 
includes the App Service plan's symbolic name on this line: serverFarmId: appServicePlan.id. 
This line means that Bicep will get the App Service plan's resource ID using the id property. 
It's effectively saying: this app's server-farm ID is the ID of the App Service plan defined earlier.
*/
 /*
 In Azure, a resource ID is a unique identifier for each resource. 
 The resource ID includes the Azure subscription ID, the resource group name, and the resource name, 
 along with some other information.
 */
