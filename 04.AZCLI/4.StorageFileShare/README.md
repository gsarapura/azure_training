```bash
https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share?tabs=azure-cli

RG_NAME=storagetest 
LOCATION=eastus

az group create --name $RG_NAME --location $LOCATION

SA_NAME=filesharesuvtestdsa124
SA_ACCOUNT_KIND="FileStorage" 
# Valid SKUs for provisioned v2 HDD file share are 'StandardV2_LRS' (HDD Local Pv2), 'StandardV2_GRS' (HDD Geo Pv2), 'StandardV2_ZRS' (HDD Zone Pv2), 'StandardV2_GZRS' (HDD GeoZone Pv2).
SA_SKU="StandardV2_LRS"
az storage account create --name $SA_NAME --resource-group $RG_NAME --location $LOCATION --sku $SA_SKU --kind $SA_ACCOUNT_KIND --min-tls-version TLS1_2 --allow-blob-public-access false

SHARE_NAME="filetestdeltea"
# The provisioned storage size of the share in GiB. Valid range is 32 to
# 262,144.
PROV_STORAGE_GiB=1024
# If you do not specify on the ProvisionedBandwidthMibps and ProvisionedIops, the deployment will use the recommended provisioning.
PROVISIONED_IOPS=3000
PROVISIONED_THROUGHPUT_MiB_Per_SEC=130

az storage share-rm create --resource-group $RG_NAME --name $SHARE_NAME --storage-account $SA_NAME --quota $PROV_STORAGE_GiB
# --provisioned-iops $provisionedIops --provisioned-bandwidth-mibps $provisionedThroughputMibPerSec

# WINDOWS
https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows
$resourceGroupName = "<your-resource-group-name>"
$storageAccountName = "<your-storage-account-name>"

# This command requires you to be logged into your Azure account and set the subscription your storage account is under, run:
# Connect-AzAccount -SubscriptionId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
# if you haven't already logged in.
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

# The ComputerName, or host, is <storage-account>.file.core.windows.net for Azure Public Regions.
# $storageAccount.Context.FileEndpoint is used because non-Public Azure regions, such as sovereign clouds
# or Azure Stack deployments, will have different hosts for Azure file shares (and other storage resources).
Test-NetConnection -ComputerName ([System.Uri]::new($storageAccount.Context.FileEndPoint).Host) -Port 445

# Linux
https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux?tabs=Ubuntu%2Csmb311
sudo apt update
sudo apt install cifs-utils

# Check PORT 445
RESOURCE_GROUP_NAME="storagetest"
STORAGE_ACCOUNT_NAME="filesharesuvtestdsa124"

# This command assumes you have logged in with az login
HTTP_ENDPOINT=$(az storage account show \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --query "primaryEndpoints.file" --output tsv | tr -d '"')
SMBPATH=$(echo $HTTP_ENDPOINT | cut -c7-${#HTTP_ENDPOINT})
FILE_HOST=$(echo $SMBPATH | tr -d "/")

nc -zvw3 $FILE_HOST 445


# MOUNT
RESOURCE_GROUP_NAME="storagetest"
STORAGE_ACCOUNT_NAME="filesharesuvtestdsa124"
FILE_SHARE_NAME="filetestdeltea"

MNT_ROOT="/media"
MNT_PATH="$MNT_ROOT/$STORAGE_ACCOUNT_NAME/$FILE_SHARE_NAME"

sudo mkdir -p $MNT_PATH

# Connect 
# Create a folder to store the credentials for this storage account and
# any other that you might set up.
CREDENTIAL_ROOT="/etc/smbcredentials"
sudo mkdir -p "/etc/smbcredentials"

# Get the storage account key for the indicated storage account.
# You must be logged in with az login and your user identity must have
# permissions to list the storage account keys for this command to work.
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query "[0].value" --output tsv | tr -d '"')

# Create the credential file for this individual storage account
SMB_CREDENTIAL_FILE="$CREDENTIAL_ROOT/$STORAGE_ACCOUNT_NAME.cred"
if [ ! -f $SMB_CREDENTIAL_FILE ]; then
    echo "username=$STORAGE_ACCOUNT_NAME" | sudo tee $SMB_CREDENTIAL_FILE > /dev/null
    echo "password=$STORAGE_ACCOUNT_KEY" | sudo tee -a $SMB_CREDENTIAL_FILE > /dev/null
else
    echo "The credential file $SMB_CREDENTIAL_FILE already exists, and was not modified."
fi

# Change permissions on the credential file so only root can read or modify the password file.
sudo chmod 600 $SMB_CREDENTIAL_FILE


## MOUNT
# This command assumes you have logged in with az login
HTTP_ENDPOINT=$(az storage account show --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" --output tsv | tr -d '"')
SMB_PATH=$(echo $HTTP_ENDPOINT | cut -c7-${#HTTP_ENDPOINT})$FILE_SHARE_NAME

STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv | tr -d '"')

sudo mount -t cifs $SMB_PATH $MNT_PATH -o credentials=$SMB_CREDENTIAL_FILE,serverino,nosharesock,actimeo=30,mfsymlinks
```