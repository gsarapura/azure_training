# SharpAI License Suvinil QA Infra

## Overview
Here are two infrastructure, one containing a simple storage account for saving tfstate securely, other containing services in which regression test will be saved.

## Prerequisites
- Login into AZ
```sh
az login
# Check account:
az account show
```
- Check status of services created to save tfstate securely. If any of these resources do no exist, it means that it's the first time setting up this project or they were deleted unexpectedly.
```bash
./scripts/az-remote-backend.bash check

# First time
./scripts/az-remote-backend.bash create
```
- Make sure the following image exists in Azure Container Registry `suvinil-qa-regression-tests:latest`:
```bash
az acr repository show-tags --name suvinilqainfraacr --repository suvinil-qa-regression-tests --query "[?contains(@, 'latest')]" -o tsv
```

- Set environment variables:
```bash
RESOURCE_GROUP_NAME=suvinil-tfstates
STORAGE_ACCOUNT_NAME=tfstatestorage17189
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY

PROJECT_NAME="sharpai-license-suvinil-qa-infra"
# Set Subscription ID
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
# Set environment: prod or dev
ENV="prod"
ENV="dev"
```

## Setup
- In root directory:
```bash
# Initialize Terraform:
terraform init
# Create new workspace:
terraform workspace new "$ENV"
# List Terraform workspaces:
terraform workspace list
```

## Handle States
- In root directory:
```bash
# List Terraform workspaces:
terraform workspace list
# Select Workspace:
terraform workspace select "$ENV"

# Plan state
terraform plan -var-file=environments/$ENV.tfvars --out "$PROJECT_NAME-$ENV.tfplan"
terraform apply "$PROJECT_NAME-$ENV.tfplan"


# Destroy
terraform plan -var-file=environments/$ENV.tfvars -destroy -out "$PROJECT_NAME-$ENV.destroy.tfplan"
terraform apply "$PROJECT_NAME-$ENV.destroy.tfplan"
```

## Refresh State with Deployed Services
```bash
# List Terraform workspaces:
terraform workspace list
# Select Workspace:
terraform workspace select "$ENV"
terraform refresh -var-file=environments/$ENV.tfvars 
```