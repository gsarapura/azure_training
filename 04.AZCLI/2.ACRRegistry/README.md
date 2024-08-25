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
