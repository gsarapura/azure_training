# Project Name

## Prerequisites
- Login into AZ
```sh
az login
# Check account:
az account show
```

- Set environment variables:
```bash
PROJECT_NAME=""
# Set Subscription ID
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
# Set environment
ENV=""
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
terraform apply "plans/$PROJECT_NAME-$ENV.tfplan"


# Destroy
terraform plan -var-file=environments/$ENV.tfvars -destroy -out "$PROJECT_NAME-$ENV.destroy.tfplan"
terraform apply "plans/$PROJECT_NAME-$ENV.destroy.tfplan"
```

## Refresh State with Deployed Services
```bash
# List Terraform workspaces:
terraform workspace list
# Select Workspace:
terraform workspace select "$ENV"
terraform refresh -var-file=environments/$ENV.tfvars 
```