/*
During the process, you'll:

Create a template that defines a single storage account resource that includes hard-coded values.
Provision your infrastructure and verify the result.
Add an App Service plan and app to the template.
Provision the infrastructure again to see the new resources.
*/

/*
 Storage accounts and App Service apps need globally unique names
 App Service plan names need to be unique only within their resource grou
*/

// param location string = resourceGroup().location // This should be used, but for sandbox:
param location string = 'westus3'
param storageAccountName string = 'stoylaunch${uniqueString(resourceGroup().name)}'
param appServiceAppName string = 'saratoylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccountPepito 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName 
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
