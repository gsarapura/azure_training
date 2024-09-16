## Simple Tutorial
```bash
RESOURCE_GROUP=ACRTest 
az group create --name $RESOURCE_GROUP --location eastus
ACR_NAME=containertest1234
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
# Check in output: loginServer
# "loginServer": "${ACR_NAME}.azurecr.io",

# Login
az acr login --name $ACR_NAME

# Pull test image
docker pull mcr.microsoft.com/hello-world

# Tagging and pushing
az acr list -o table

TAG_VERSION=1.0.0
docker tag mcr.microsoft.com/hello-world $ACR_NAME.azurecr.io/hello-world:$TAG_VERSION
docker push $ACR_NAME.azurecr.io/hello-world:$TAG_VERSION

## Retagging
az acr import --name $ACR_NAME --source $ACR_NAME.azurecr.io/hello-world:$TAG_VERSION --image hello-world:qa --force

# Enabling Admin User to do docker login etc:
az acr update -n $ACR_NAME --admin-enabled true
```

## Establishing Service Connection Via Managed Identities
Managed Identities are a kind of Service Principal attached to a specific Azure Service.
```bash
az login
# Find subscription and tenant ID
az account list
az account tenant list

```

## Creating a Service Principal
```bash
az ad sp list --all -o table
az ad sp show --id $APP_ID -o table
```

## Build and Deploy Docker Image
```bash
# Login into Azure and registry
az login
REGISTRY_NAME=""
az acr login --name $REGISTRY_NAME

# Build image
IMAGE_NAME_VERSION=":latest"
docker build -t $IMAGE_NAME_VERSION .

# Optional - Run locally
CONTAINER_NAME=""
docker run -e ENV_1='' \
           -e ENV_2='' \
            --name $CONTAINER_NAME $IMAGE_NAME_VERION 

# Tag and push image
docker tag $IMAGE_NAME_VERSION $REGISTRY_NAME.azurecr.io/$IMAGE_NAME_VERSION
docker push $REGISTRY_NAME.azurecr.io/$IMAGE_NAME_VERSION
```

## Updating Container App Job
- Create config.yaml:
```yaml
configuration:
    triggerType: Schedule
    scheduleTriggerConfig:
        cronExpression: "*/5 * * * *"
```
- Update using AZ CLI:
```bash
CONTAINER_NAME=""
RESOURCE_GROUP=""
CONFIG=""
az containerapp job update --name $CONTAINER_NAME --resource-group $RESOURCE_GROUP --yaml $CONFIG
```
