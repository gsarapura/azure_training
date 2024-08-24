## Azure Service Principal for RBAC
1 - Download Azure CLI from here, run az login to login with your Azure Credentials.
```sh
az login
```

2 - Run Azure CLI command to create an Azure Service Principal for RBAC:
```sh
RESOURCE_GROUP_ID=$(az group show --name $RESOURCE_NAME --query id --output tsv)

SP_NAME=GitHubActionSP
ROLE=contributor 
RESOURCE_ID=
az ad sp create-for-rbac --name "$SP_NAME" --role "$ROLE" --scopes $RESOURCE_ID --json-auth
```

The command should output a JSON object similar to this:
```json
{
"clientId": "<GUID>",
"clientSecret": "<GUID>",
"subscriptionId": "<GUID>",
"tenantId": "<GUID>",
(...)
}
```

3 - (Optional) List and delete:
``` sh
az ad sp list --display-name $SP_NAME
APP_ID=$(az ad sp list --display-name $SP_NAME | jq -r '.[0].appId')
az ad sp delete --id $APP_ID
```

## Save credentials to GitHub repo
1 - In the GitHub UI, navigate to your repository and select Settings > Security > Secrets and variables > Actions.
2 - Select New repository secret to add the following secrets:
Secret          	    Value

AZURE_CREDENTIALS	    The entire JSON output from the service principal creation step
REGISTRY_LOGIN_SERVER	The login server name of your registry (all lowercase). Example: myregistry.azurecr.io
REGISTRY_USERNAME	    The clientId from the JSON output from the service principal creation
REGISTRY_PASSWORD	    The clientSecret from the JSON output from the service principal creation

```json
{
  "clientId": "",
  "clientSecret": "",
  "subscriptionId": "",
  "tenantId": "",
  "activeDirectoryEndpointUrl": "",
  "resourceManagerEndpointUrl": "",
  "activeDirectoryGraphResourceId": "",
  "sqlManagementEndpointUrl": "",
  "galleryEndpointUrl": "",
  "managementEndpointUrl": ""
}
```
## Create workflow file
1 - In the GitHub UI, select Actions.
2 - Select set up a workflow yourself.
3 - In Edit new file, paste the following YAML contents to overwrite the sample code. Accept the default filename main.yml, or provide a filename you choose.
4 - Select Start commit, optionally provide short and extended descriptions of your commit, and select Commit new file.
```yaml
on:
  push:
    branches:
      - 'main'
name: Linux_Container_Workflow

jobs:
    build-and-deploy:
        runs-on: ubuntu-latest
        env:
          IMAGE_NAME: ${{ secrets.REGISTRY_LOGIN_SERVER }}/cygnal-dbt-job:latest
        steps:
        # checkout the repo
        - name: 'Checkout GitHub Action'
          uses: actions/checkout@main
          
        - name: 'Login via Azure CLI'
          uses: azure/login@v2
          with:
            creds: ${{ secrets.AZURE_CREDENTIALS }}
        
        - name: 'Build and push image'
          uses: azure/docker-login@v2
          with:
            login-server: ${{ secrets.REGISTRY_LOGIN_SERVER }}
            username: ${{ secrets.REGISTRY_USERNAME }}
            password: ${{ secrets.REGISTRY_PASSWORD }}
        - run: |
            docker build cygnal_dbt/ -t $IMAGE_NAME
            docker push $IMAGE_NAME
```
