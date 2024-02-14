# Parameter files
In the previous units, you provided the parameter values on the command line when you created a deployment. This approach works well when you're writing and testing your Bicep files, but it doesn't work well when you have many parameters or when you need to automate your deployments.

- *$schema* helps Azure Resource Manager to understand that this file is a parameter file.
- *contentVersion* is a property that you can use to keep track of significant changes in your parameter file if you want. Usually, it's set to its default value of 1.0.0.0.
- The *parameters* section lists each parameter and the value you want to use. The parameter value must be specified as an object. The object has a property called value that defines the actual parameter value to use.

For example, you might have a parameter file named `main.parameters.dev.json` for your development environment and one named `main.parameters.production.json` for your production environment.

# Command
az deployment group create \
  --template-file main.bicep \
  --parameters main.parameters.json

# Hierarchy
1. Parameters specified on command line
2. Parameter file
3. Default values in bicep template
Parameter files override default values, and command-line parameter values override parameter files.

# Define secure parameters
When you define a parameter as @secure, Azure won't make the parameter values available in the deployment logs. Also, if you create the deployment interactively by using the Azure CLI or Azure PowerShell and you need to enter the values during the deployment, the terminal won't display the text on your screen.

*Tip*
Make sure you don't create outputs for sensitive data. Output values can be accessed by anyone who has access to the deployment history. They're not appropriate for handling secrets.

# Avoid using parameter files for secrets -> Azure Key Vault
You can integrate your Bicep templates with Key Vault by using a parameter file with a reference to a Key Vault secret.

*Tip*
You can refer to secrets in key vaults that are located in a `different resource group or subscription` from the one you're deploying to.

@secure()
param sqlServerAdministratorLogin string

@secure()
param sqlServerAdministratorPassword string

{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "sqlServerAdministratorLogin": {
      *"reference"*: {
        "keyVault": {
          "id": "/subscriptions/f0750bbe-ea75-4ae5-b24d-a92ca601da2c/resourceGroups/PlatformResources/providers/Microsoft.KeyVault/vaults/toysecrets"
        },
        "secretName": "sqlAdminLogin"
      }
    },
    "sqlServerAdministratorPassword": {
      *"reference"*: {
        "keyVault": {
          "id": "/subscriptions/f0750bbe-ea75-4ae5-b24d-a92ca601da2c/resourceGroups/PlatformResources/providers/Microsoft.KeyVault/vaults/toysecrets"
        },
        "secretName": "sqlAdminLoginPassword"
      }
    }
  }
}

## Important
Your key vault must be configured to allow Resource Manager to access the data in the key vault during template deployments. Also, the user who deploys the template must have permission to access the key vault. 

# Use Key Vault with modules
Modules enable you to create reusable Bicep files that encapsulate a set of resources. It's common to use modules to deploy parts of your solution. Modules may have parameters that accept secret values, and you can use Bicep's Key Vault integration to provide these values securely. Here's an example Bicep file that deploys a module and provides the value of the ApiKey secret parameter by taking it directly from Key Vault:
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

module applicationModule 'application.bicep' = {
  name: 'application-module'
  params: {
    *apiKey: keyVault.getSecret('ApiKey')*
  }
}

Notice that in this Bicep file, the Key Vault resource is referenced by using the `existing` keyword. The keyword tells Bicep that the Key Vault already exists, and this code is a reference to that vault. Bicep *won't redeploy it*. Also, notice that the module's code uses the `getSecret()` function in the value for the module's `apiKey` parameter. This is a special Bicep function that can only be used with secure module parameters. Internally, Bicep translates this expression to the same kind of Key Vault reference you learned about earlier.

## Create Key Vault and Secrets
For the keyVaultName replace YOUR-KEY-VAULT-NAME with a name for your key vault. The read commands for the login and password variables will prompt you for values. As you type, the values aren't displayed in the terminal and aren't saved in your command history.

To protect the variable values in your Bash terminal session, be aware of the following items:

Variable values aren't stored as a secure string and can be displayed by entering a command like $yourVariableName on the command line or with the echo command. In this exercise, after your vault secrets are created, you can remove each variable's existing value by running the read commands without inputting a value.
The az keyvault secret set uses the --value parameter to create a secret's value. The command's output displays a property named value that contains the secret's value. You can suppress the command's entire output with the parameter --output none as shown in the example.
To create the keyVaultName, login, and password variables, run each command separately. Then you can run the block of commands to create the key vault and secrets.

keyVaultName='YOUR-KEY-VAULT-NAME'
read -s -p "Enter the login name: " login
read -s -p "Enter the password: " password

az keyvault create --name $keyVaultName --location westus3 --enabled-for-template-deployment true
az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorLogin" --value $login --output none
az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorPassword" --value $password --output none

*Note*
You're setting the --enabled-for-template-deployment setting on the vault so that Azure can use the secrets from your vault during deployments. If you don't set this setting then, by default, your deployments can't access secrets in your vault.

Also, whoever executes the deployment must also have permission to access the vault. Because you created the key vault, you're the owner, so you won't have to explicitly grant the permission in this exercise. For your own vaults, you need to grant access to the secrets.
`https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/key-vault-parameter?tabs=azure-cli#grant-access-to-the-secrets`

# Use .bicepparam files
https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files?tabs=Bicep 