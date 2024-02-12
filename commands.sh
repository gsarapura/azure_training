# Install AZ CLI 
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

# Sign in to Azure
az bicep install && az bicep upgrade
az login
az account set --subscription "Concierge Subscription"
# Skip following two step if only one subscription is enabled
az account list \
   --refresh \
   --query "[?contains(name, 'Concierge Subscription')].id" \
   --output table
az account set --subscription {your subscription ID}
#
# Set the default resource group
az configure --defaults group=[sandbox resource group name]

# Deploy
az deployment group create --template-file main.bicep
az deployment group create --template-file main.bicep --parameters environmentType=nonprod

# Check deployments
az deployment group list --output table
