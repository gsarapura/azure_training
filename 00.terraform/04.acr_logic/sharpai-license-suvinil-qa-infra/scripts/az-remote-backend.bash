#!/bin/bash
RESOURCE_GROUP_NAME=suvinil-tfstates
STORAGE_ACCOUNT_NAME=tfstatestorage17189
CONTAINER_NAME=regression-tests-tfstate

# Check if an argument is passed
if [ "$#" -ne 1 ]; then
    echo "One of the options must be passed 'check' or 'create'"
    exit 1
fi

if [ "$1" == "check" ]; then
    # Check resource group
    if az group show --name $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
        echo "Resource group '$RESOURCE_GROUP_NAME' exists."
    else
        echo "Resource group '$RESOURCE_GROUP_NAME' does not exist."
    fi

    # Check storage account
    if az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
        echo "Storage account '$STORAGE_ACCOUNT_NAME' exists."

        # Check blob container
        if az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME > /dev/null 2>&1; then
            echo "Blob container '$CONTAINER_NAME' exists."
        else
            echo "Blob container '$CONTAINER_NAME' does not exist."
        fi
    else
        echo "Storage account '$STORAGE_ACCOUNT_NAME' does not exist."
        echo "Blob container '$CONTAINER_NAME' does not exist."
    fi

# Create resource group, storage account, and blob container
elif [ "$1" == "create" ]; then
    # Create resource group if it does not exist
    if ! az group show --name $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
        az group create --name $RESOURCE_GROUP_NAME --location eastus
        echo "Resource group '$RESOURCE_GROUP_NAME' created."
    else
        echo "Resource group '$RESOURCE_GROUP_NAME' already exists."
    fi

    # Create storage account if it does not exist
    if ! az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
        az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --min-tls-version TLS1_3
        echo "Storage account '$STORAGE_ACCOUNT_NAME' created."
    else
        echo "Storage account '$STORAGE_ACCOUNT_NAME' already exists."
    fi

    # Create blob container if it does not exist
    if ! az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME > /dev/null 2>&1; then
        az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
        echo "Blob container '$CONTAINER_NAME' created."
    else
        echo "Blob container '$CONTAINER_NAME' already exists."
    fi
else
    echo "One of the options must be passed 'check' or 'create'"
    exit 1
fi