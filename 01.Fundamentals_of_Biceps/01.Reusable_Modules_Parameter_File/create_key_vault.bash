#! /bin/bash

keyVaultName='YOUR-KEY-VAULT-NAME'
read -s -p "Enter the login name: " login
read -s -p "Enter the password: " password

az keyvault create --name $keyVaultName  --location westus3 --enabled-for-template-deployment true

az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorLogin" --value $login --output none 

az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorPassword"  --value $password --output none

az keyvault show --name $keyVaultName --query id --output tsv