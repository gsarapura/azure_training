#!/bin/bash
# Function to display usage
usage() {
    echo "Usage: $0 (check-mock-image|create-mock-image) --acr ACR_NAME --server LOGIN_SERVER --image IMAGE_NAME --tag TAG_NAME"
    exit 1
}

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    usage
fi

# Parse the action
ACTION=$1
shift

# Initialize variables
ACR_NAME=""
LOGIN_SERVER=""
IMAGE_NAME=""
TAG_NAME=""

# Parse the options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --acr) ACR_NAME="$2"; shift ;;
        --server) LOGIN_SERVER="$2"; shift ;;
        --image) IMAGE_NAME="$2"; shift ;;
        --tag) TAG_NAME="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Check if all required parameters are provided
if [ -z "$ACR_NAME" ] || [ -z "$LOGIN_SERVER" ] || [ -z "$IMAGE_NAME" ] || [ -z "$TAG_NAME" ]; then
    echo "Error: All parameters (ACR_NAME, LOGIN_SERVER, IMAGE_NAME, TAG_NAME) must be provided."
    usage
fi

if [ "$ACTION" == "check-mock-image" ]; then
    az acr repository show-tags --name "$ACR_NAME" --repository "$IMAGE_NAME" --query "[?contains(@, '$TAG_NAME')]" -o tsv
    if [ $? == $TAG_NAME ]; then
        echo "Image exists."
    else
        echo "Image does not exist."
        exit 1
    fi
elif [ "$ACTION" == "create-mock-image" ]; then
    az acr login --name "$ACR_NAME"
    docker pull mcr.microsoft.com/mcr/hello-world
    docker tag mcr.microsoft.com/mcr/hello-world "$LOGIN_SERVER/$IMAGE_NAME:$TAG_NAME"
    docker push "$LOGIN_SERVER/$IMAGE_NAME:$TAG_NAME"
else
    echo "Only check-mock-image and create-mock-image are available"
    exit 1
fi
