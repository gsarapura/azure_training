# Azure Front Door Using AZ CLI
https://learn.microsoft.com/en-us/azure/frontdoor/quickstart-create-front-door-cli
```bash
# Ensure that the front-door extension is added to your Azure CLI
az extension add --name front-door

RG_NAME=myRGFDCentral 
LOCATION=eastus

# RG
az group create --name $RG_NAME --location $LOCATION

# Create two instances of a web app
## Create app service plans
AS_NAME=myAppServicePlanCentralUS 
az appservice plan create --name $AS_NAME --resource-group $RG_NAME 

## Create web apps
WEB_APP_NAME=WebAppContoso-1-asdf
az webapp create --name $WEB_APP_NAME --resource-group $RG_NAME --plan $AS_NAME

## Create Storage Account - Frontend
az storage account create --name frontendtestsuv1 --resource-group $RG_NAME --location $LOCATION --sku Standard_RAGRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false

az storage account create --name frontendtestsuv2 --resource-group $RG_NAME --location $LOCATION --sku Standard_RAGRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false

## Enable Hosting
# https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-cli 
# Activate hosting
SA_NAME=frontendtestsuv2
az storage blob service-properties update --account-name $SA_NAME --static-website --404-document error.html --index-document index.html
# Upload Content
az storage blob upload-batch -s . -d '$web' --account-name $SA_NAME --overwrite
# Find URL
az storage account show -n $SA_NAME -g $RG_NAME  --query "primaryEndpoints.web" --output tsv
# https://$SA_NAME.z13.web.core.windows.net/

 # Create Front Door - CLASSIC
BACKEND_ADDRESS=webappcontoso-1-asdf.azurewebsites.net
FD_NAME=constososuvibilfronted2
az network front-door create --resource-group $RG_NAME --name $FD_NAME --accepted-protocols Http Https --backend-address $BACKEND_ADDRESS

# 
HOST_NAME=frontendtestsuv1.z13.web.core.windows.net
az network front-door check-custom-domain --host-name $HOST_NAME \
                                          --name $FD_NAME \
                                          -g $RG_NAME
FE_NAME=NewSuvFrontEndpoint
az network front-door frontend-endpoint create --front-door-name $FD_NAME \
                                               --host-name $HOST_NAME \
                                               --name $FE_NAME \
                                               --resource-group $RG_NAME

ADDRESS=
POOL_NAME=suvinilfront1
az network front-door backend-pool backend add --address $ADDRESS \
                                               --front-door-name $FD_NAME \
                                               --pool-name $POOL_NAME \
                                               --resource-group $RG_GROUP

az network front-door backend-pool backend list --front-door-name $FD_NAME \
                                                --pool-name $POOL_NAME \
                                                --resource-group $RG_NAME

RR_NAME=DefaultRoutingRule 
az network front-door routing-rule show --front-door-name $FD_NAME \
                                        --name $RR_NAME \
                                        --resource-group $RG_NAME
 ```