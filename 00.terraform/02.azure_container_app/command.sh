#!/bin/bash
# https://learn.microsoft.com/en-us/azure/container-apps/jobs?tabs=azure-cli
az containerapp job create \
    --name "my-job" --resource-group "learn-50e107c3-741e-48ad-a0c2-f471225d7663"  --environment "my-environment" \
    --trigger-type "Manual" \
    --replica-timeout 1800 \
    --image "mcr.microsoft.com/k8se/quickstart-jobs:latest" \
    --cpu "0.25" --memory "0.5Gi"