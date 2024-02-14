# Example Scenario 
You expect that the toy will be very popular, and your company plans to launch it in new countries/regions regularly. Every country/region where you launch the smart teddy bear will need a separate database server and virtual network. To comply with each country's/region's laws, you'll need to physically place these resources in specific locations. You've been asked to deploy each country's/region's database servers and virtual networks and, at the same time, make it easy to add logical servers and virtual networks as the toy is launched in new countries/regions.

Resource Group: {
    eastus: {Virtual Network + AzureSQL}
    westeurope: {Virtual Network + AzureSQL}
    eastasia: {Virtual Network + AzureSQL}
}

# Goals
- Use conditions to deploy Azure resources only when they're required.
- Use loops to deploy multiple instances of Azure resources.
- Learn how to control loop parallelism.
- Learn how to create nested loops.
- Combine loops with variables and outputs.

# Conditions:
`param deployStorageAccount bool`

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = *if (deployStorageAccount)* {...}

--------------------------------------------------

@allowed([
  'Development'
  'Production'
])
`param environmentName string`

var auditingEnabled = environmentName == 'Production'

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = *if (auditingEnabled)* {...}

*Note*
If you have several resources, all with the same condition for deployment, consider using Bicep modules. You can create a module that deploys all the resources, then put a condition on the module declaration in your main Bicep file.

# Loops
https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/4-use-loops-deploy-resources
