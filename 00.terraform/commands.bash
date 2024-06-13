#!/bin/bash
# As always, set your user:
# Sign in to Azure
az login
az account set --subscription "Concierge Subscription"
# Skip following two step if only one subscription is enabled
az account list \
   --refresh \
   --query "[?contains(name, 'Concierge Subscription')].id" \
   --output table
az account set --subscription "your subscription ID"

# Create resource group:
az group create --name demoResourceGroup --location eastus

# Set the default resource group
az configure --defaults group=[sandbox resource group name]

# Now terraform:
terraform init
# Run
terraform plan
# to determine what actions are necessary to create the configuration that you specified in your
# configuration files. Running the command creates an execution plan but doesn't apply it. This pattern allows you to
# verify if the execution plan matches your expectations before you make any changes to actual resources.
terraform plan -out main.tfplan
terraform plan -var="resource_group_name=NAME"
# After you verify the execution plan, run terraform apply to apply the plan. This command creates the defined resources.
terraform apply main.tfplan
terraform apply -var="resource_group_name=NAME"
# Verify resource deployed, in this case a storage account
terraform state show 'azurerm_storage_account.example'

# Destroy
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan