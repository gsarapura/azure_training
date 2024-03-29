#! /bin/bash
keyVaultName='YOUR-KEY-VAULT-NAME'
read -s -p "Enter the AzureWebJobsStorage: " AzureWebJobsStorage 
echo -e "\nAzureWebJobsStorage set: $AzureWebJobsStorage\n"
read -s -p "Enter the WebsiteContentAzureFileConnectionString: " WebsiteContentAzureFileConnectionString
echo -e "\nWebsiteContentAzureFileConnectionString set: $WebsiteContentAzureFileConnectionString"

az keyvault create \
    --name $keyVaultName \
    --location eastus \
    --enabled-for-template-deployment true

az keyvault secret set \
    --vault-name $keyVaultName \
    --name "AzureWebJobsStorage" \
    --value $login \
    --output none

az keyvault secret set \
    --vault-name $keyVaultName \
    --name "WebsiteContentAzureFileConnectionString" \
    --value $WebsiteContentAzureFileConnectionString \
    --output none

az keyvault show --name $keyVaultName --query id --output tsv
