# Install AZ CLI 
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

# Install and upgrade bicep
az bicep install && az bicep upgrade
# Sign in to Azure
az login
az account set --subscription "Concierge Subscription"
# Skip following two step if only one subscription is enabled
az account list \
   --refresh \
   --query "[?contains(name, 'Concierge Subscription')].id" \
   --output table
az account set --subscription {your subscription ID}

# Create resource group:
az group create --name demoResourceGroup --location eastus

# Set the default resource group
az configure --defaults group=[sandbox resource group name]

# Deploy
az deployment group create --template-file main.bicep
# Using parameters
az deployment group create --template-file main.bicep --parameters environmentType=nonprod
# Using parameter file
az deployment group create \
  --template-file main.bicep \
  --parameters main.parameters.json

# Check deployments
az deployment group list --output table

# Create Key Vault and Secrets
# Key vault names must be a globally unique string of 3 to 24 characters that can contain only 
# uppercase and lowercase letters, hyphens (-), and numbers. For example, demo-kv-1234567abcdefg.
keyVaultName='YOUR-KEY-VAULT-NAME'
read -s -p "Enter the login name: " login
read -s -p "Enter the password: " password

az keyvault create --name $keyVaultName --location westus3 --enabled-for-template-deployment true
az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorLogin" --value $login --output none
az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorPassword" --value $password --output none

# Get Key Vault's ID
az keyvault show --name $keyVaultName --query id --output tsv

# Give Access to Key Vault
az keyvault set-policy \
  --upn <user-principal-name> \
  --name ExampleVault \
  --secret-permissions set delete get list
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli