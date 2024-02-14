resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'toylaunchstorage'
  location: 'westus3' 
  sku:{
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

/* storageAccount: Symbolic name. Symbolic names are used within Bicep to refer to the resource, 
but they won't ever show up in Azure. I could call it pepito, if I wanted to */
// Microsoft.Storage/storageAccount: Declaring a storage account - Its version: @2022-09-01
// name: In contrast to symbolic name, this does appear in Azure. 
// Different API version may introduce more properties.


